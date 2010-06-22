# @(#)$Id$

package HTML::FormWidgets::File;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);
use IO::File;
use Syntax::Highlight::Perl;
use Text::ParseWords;
use Text::Tabs;

__PACKAGE__->mk_accessors( qw(base header header_class hide path root
                              scheme select style subtype) );

my %SCHEME =
   ( Variable_Scalar   => [ '<font color="#CC6600">', '</font>' ],
     Variable_Array    => [ '<font color="#FFCC00">', '</font>' ],
     Variable_Hash     => [ '<font color="#990099">', '</font>' ],
     Variable_Typeglob => [ '<font color="#000000">', '</font>' ],
     Subroutine        => [ '<font color="#339933">', '</font>' ],
     Quote             => [ '<font color="#000000">', '</font>' ],
     String            => [ '<font color="#3399FF">', '</font>' ],
     Comment_Normal    => [ '<font color="#ff0000"><i>', '</i></font>' ],
     Comment_POD       => [ '<font color="#ff9999">', '</font>' ],
     Bareword          => [ '<font color="#000000">', '</font>' ],
     Package           => [ '<font color="#000000">', '</font>' ],
     Number            => [ '<font color="#003333">', '</font>' ],
     Operator          => [ '<font color="#999999">', '</font>' ],
     Symbol            => [ '<font color="#000000">', '</font>' ],
     Keyword           => [ '<font color="#0000ff"><b>', '</b></font>' ],
     Builtin_Operator  => [ '<font color="#000000">', '</font>' ],
     Builtin_Function  => [ '<font color="#000000">', '</font>' ],
     Character         => [ '<font color="#3399FF"><b>', '</b></font>' ],
     Directive         => [ '<font color="#000000"><i><b>',
                           '</b></i></font>' ],
     Label             => [ '<font color="#000000">', '</font>' ],
     Line              => [ '<font color="#000000">', '</font>' ], );

sub init {
   my ($self, $args) = @_;

   $self->base        ( q()            );
   $self->container   ( 0              );
   $self->header      ( []             );
   $self->header_class( q(small table) );
   $self->hide        ( []             );
   $self->path        ( undef          );
   $self->root        ( undef          );
   $self->scheme      ( \%SCHEME       );
   $self->select      ( -1             );
   $self->style       ( q()            );
   $self->subtype     ( q(file)        );
   return;
}

sub render_field {
   # Subtypes: file, csv, html, source, and logfile
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $path = $self->path or return 'Path not specified';

   $self->subtype eq q(html) and return $self->_render_html( $hacc, $path );

   -f $path or return "Path $path not found";

   my $rdr    = IO::File->new( $path, q(r) ) or return "Path $path cannot read";
   my $text   = do { local $RS = undef; <$rdr> }; $rdr->close;
   my $method = q(_render_).($self->subtype || q(file));

   return $self->$method( $hacc, $text );
}

# Private subroutines

sub _add_row_count {
   my ($self, $default) = @_;

   my $content = $self->inflate( { name    => q(_).($self->id || q()).q(_nrows),
                                   default => $default,
                                   type    => q(hidden),
                                   widget  => 1 } );

   push @{ $self->hide }, { content => $content };
   return;
}

sub _add_select_box {
   my ($self, $hacc, $r_no, $c_no, $val) = @_;

   my $box   = $hacc->checkbox( { label => q(),
                                  name  => q(select).$r_no,
                                  value => $val } );
   my $class = $self->subtype.q( ).__column_class( $c_no );

   return $hacc->td( { class => $class }, $box );
}

sub _build_table {
   my ($self, $hacc, $text, $header_cells, $row_cells) = @_;

   my ($class, $lead, $val); my $r_no = 0; my $rows = q(); my $c_max = 1;

   for my $line (split m { \n }mx, $text) {
      my $c_no = 0; $line = $hacc->escape_html( $line, 0 );

      my ($ncells, $cells, $val) = $row_cells->( $hacc, $line, $r_no );

      if ($cells) {
         $class = q(lineNumber ).__column_class( $c_no++ );
         $lead  = $hacc->td( { class => $class }, $r_no + 1 );
         $self->select >= 0
            and $lead .= $self->_add_select_box( $hacc, $r_no, $c_no++, $val );
         $rows .= $hacc->tr( { class => $self->subtype }, $lead.$cells );
         $r_no++;
      }

      $c_no += $ncells; $c_no > $c_max and $c_max = $c_no;
   }

   $class = $self->header_class.q( minimal);

   my $cells = $hacc->th( { class => $class }, chr 35 );

   $self->select >= 0 and $cells .= $hacc->th( { class => $class }, 'M' );
   $cells .= $header_cells->( $hacc, $c_max, $self->select < 0 ? 1 : 2 );
   $rows   = $hacc->tr( $cells ).$rows;
   $self->_add_row_count( $r_no );

   return $hacc->table( { class => $self->subtype }, $rows );
}

sub _render_csv {
   my ($self, $hacc, $text) = @_;

   my $header_cells = sub {
      my ($hacc, $c_max, $c_no) = @_; my $cells = q();

      my @headers = $self->header->[0] ? @{ $self->header } : ('A' .. 'Z');

      for my $header (@headers) {
         $cells .= $hacc->th( { class => $self->header_class }, $header );
         ++$c_no >= $c_max and last;
      }

      return $cells;
   };
   my $row_cells = sub {
      my ($hacc, $line, $r_no) = @_;

      my $cells = q(); my $f_no = 0; my $val = q();

      for my $fld (parse_line( q(,), 0, $line )) {
         if ($r_no == 0 and $line =~ m{ \A \# }mx) {
            $f_no == 0 and $fld = substr $fld, 1;
            $self->header->[ $f_no ] = $fld;
         }
         else {
            my $class = $self->subtype.q( ).__column_class
               ( ($self->select < 0 ? 1 : 2) + $f_no );

            $cells .= $hacc->td( { class => $class }, $fld );
         }

         $f_no == $self->select and $val = $fld; $f_no++;
      }

      return ($f_no, $cells, $val);
   };

   return $self->_build_table( $hacc, $text, $header_cells, $row_cells );
}

sub _render_file {
   my ($self, $hacc, $text) = @_;

   my $header_cells = sub {
      my ($hacc, $c_max, $c_no) = @_;

      return $hacc->th( { class => $self->header_class }, 'Lines' );
   };
   my $row_cells = sub {
      my ($hacc, $line, $r_no) = @_;

      my $cells = $hacc->td( { class => $self->subtype }, $line );

      return (1, $cells, $line);
   };

   return $self->_build_table( $hacc, $text, $header_cells, $row_cells );
}

sub _render_html {
   my ($self, $hacc, $path) = @_; my $pat = $self->root;

   $path  =~ m{ \A $pat }msx
      and $path = $self->base.($path =~ s{ \A $pat }{/}msx);
   $path  = $path =~ m{ \A http: }msx ? $path : $self->base.$path;

   my $style  = 'border: 0px; bottom: 0px; position: absolute; ';
      $style .= 'top: 0px; width: 100%; height: 100%; '.$self->style;

   return $hacc->iframe( { class     => $self->subtype,
                           src       => $path,
                           scrolling => q(auto),
                           style     => $style }, '&#160;' );
}

sub _render_logfile {
   my ($self, $hacc, $text) = @_; my $r_no = 0; my $rows = q(); my $cells;

   # TODO: Add Prev and next links to append div
   for my $line (split m { \n }mx, $text) {
      $line   = $hacc->escape_html( $line, 0 );
      $line   = $hacc->pre( { class => $self->subtype }, $line );
      $cells  = $hacc->td(  { class => $self->subtype }, $line );
      $rows  .= $hacc->tr(  { class => $self->subtype }, $cells )."\n";
      $r_no++;
   }

   $self->_add_row_count( $r_no );

   return $hacc->table( { cellpadding => 0, cellspacing => 0,
                          class       => $self->subtype }, $rows );
}

sub _render_source {
   my ($self, $hacc, $text) = @_; my $fmt = Syntax::Highlight::Perl->new();

   $fmt->set_format( $self->scheme );
   $fmt->define_substitution( q(<) => q(&lt;),
                              q(>) => q(&gt;),
                              q(&) => q(&amp;) );
   $tabstop = $self->tabstop; # Text::Tabs
   $text    = $fmt->format_string( expand( $text ) );

   return $hacc->pre( { class => $self->subtype }, $text );
}

# Private subroutines

sub __column_class {
   return $_[ 0 ] % 2 == 0 ? q(even) : q(odd);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
