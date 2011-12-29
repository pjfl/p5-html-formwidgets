# @(#)$Id$

package HTML::FormWidgets::File;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);
use IO::File;
use Syntax::Highlight::Perl;
use Text::ParseWords;
use Text::Tabs;

__PACKAGE__->mk_accessors( qw(header header_class number
                              path scheme select subtype tabstop) );

my $HASH_CHAR = chr 35;
my %SCHEME    =
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

   $self->container   ( 0         );
   $self->header      ( []        );
   $self->header_class( q(normal) );
   $self->number      ( 1         );
   $self->path        ( undef     );
   $self->scheme      ( \%SCHEME  );
   $self->select      ( -1        );
   $self->subtype     ( q(text)   );
   $self->tabstop     ( 3         );
   return;
}

sub render_field {
   # Subtypes: csv, html, logfile, source, and text
   my ($self, $args) = @_;

   my $path = $self->path or return 'Path not specified';

   $self->subtype or return 'Subtype not specified';
   $self->subtype eq q(html) and return $self->_render_html( $path );

   -f $path or return "Path $path not found";

   my $rdr    = IO::File->new( $path, q(r) ) or return "Path $path cannot read";
   my $text   = do { local $RS = undef; <$rdr> }; $rdr->close;
   my $method = q(_render_).$self->subtype;

   return $self->$method( $text );
}

# Private subroutines

sub _add_line_number {
   my ($self, $r_no, $c_no) = @_;

   my $class = q(first lineNumber).__column_class( $c_no );

   return $self->hacc->td( { class => $class }, $r_no + 1 );
}

sub _add_row_count {
   my ($self, $n_rows) = @_;

   return $self->add_hidden( q(_).($self->id || q()).q(_nrows), $n_rows );
}

sub _add_select_box {
   my ($self, $r_no, $c_no, $val) = @_; my $hacc = $self->hacc;

   my $box   = $hacc->checkbox( { label => q(),
                                  name  => q(select).$r_no,
                                  value => $val } );
   my $class = $self->subtype.__column_class( $c_no );

   return $hacc->td( { class => $class }, $box );
}

sub _build_table {
   my ($self, $text, $header_cells, $row_cells) = @_; my $hacc = $self->hacc;

   my ($cells, $class, $val); my $r_no = 0; my $rows = q(); my $c_max = 1;

   for my $line (split m{ \n }mx, $text) {
      my $c_no = 0; my $lead = q();

      my ($ncells, $cells, $val) = $row_cells->( $line, $r_no );

      if ($cells) {
         $self->number and $lead = $self->_add_line_number( $r_no, $c_no++ );
         $self->select >= 0
            and $lead .= $self->_add_select_box( $r_no, $c_no++, $val );
         $class = $self->subtype.__row_class( $r_no );
         $rows .= $hacc->tr( { class => $class }, $lead.$cells );
         $r_no++;
      }

      $c_no += $ncells; $c_no > $c_max and $c_max = $c_no;
   }

   $class = $self->header_class.q( minimal);
   $self->number
      and $cells = $hacc->th( { class => $class }, $self->loc( $HASH_CHAR ) );
   $self->select >= 0
      and $cells .= $hacc->th( { class => $class }, $self->loc( 'M' ) );
   $cells .= $header_cells->( $c_max, $self->select < 0 ? 1 : 2 );
   $rows   = $hacc->tr( $cells ).$rows;
   $self->_add_row_count( $r_no );

   return $hacc->table( { cellspacing => 0, class => $self->subtype }, $rows );
}

sub _render_csv {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   my $header_cells = sub {
      my ($c_max, $c_no) = @_; my $cells = q();

      my @headers = $self->header->[0] ? @{ $self->header } : ('A' .. 'Z');

      for my $header (@headers) {
         $cells .= $hacc->th( { class => $self->header_class }, $header );
         ++$c_no >= $c_max and last;
      }

      return $cells;
   };
   my $row_cells = sub {
      my ($line, $r_no) = @_;

      my $cells = q(); my $f_no = 0; my $val = q();

      for my $fld (parse_line( q(,), 0, $hacc->escape_html( $line, 0 ) )) {
         if ($r_no == 0 and $line =~ m{ \A \# }mx) {
            $f_no == 0 and $fld = substr $fld, 1;
            $self->header->[ $f_no ] = $fld;
         }
         else {
            my $class = $self->subtype.__column_class
               ( ($self->select < 0 ? 1 : 2) + $f_no );

            $cells .= $hacc->td( { class => $class }, $fld );
         }

         $f_no == $self->select and $val = $fld; $f_no++;
      }

      return ($f_no, $cells, $val);
   };

   return $self->_build_table( $text, $header_cells, $row_cells );
}

sub _render_html {
   my ($self, $path) = @_;  my $hacc = $self->hacc;

   my $pat = $self->options->{root};

   $path  =~ m{ \A $pat }msx
      and $path = $self->options->{base}.($path =~ s{ \A $pat }{/}msx);
   $path  = $path =~ m{ \A http: }msx ? $path : $self->options->{base}.$path;

   return $hacc->iframe( { class     => $self->subtype,
                           src       => $path,
                           scrolling => q(auto) }, '&#160;' );
}

sub _render_logfile {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   my $r_no = 0; my $rows = q(); my $cells;

   # TODO: Add Prev and next links to append div
   my $header_cells = sub {
      my ($c_max, $c_no) = @_; my $text = $self->loc( 'Logfile' );

      return $hacc->th( { class => $self->header_class }, $text );
   };
   my $row_cells = sub {
      my ($line, $r_no) = @_; $line = $hacc->escape_html( $line, 0 );

      my $class = $self->subtype.__column_class( 1 );
      my $cells = $hacc->td( { class => $class }, $line );

      return (1, $cells, $line);
   };

   return $self->_build_table( $text, $header_cells, $row_cells );
}

sub _render_source {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   my $fmt = Syntax::Highlight::Perl->new();

   $fmt->set_format( $self->scheme );
   $fmt->define_substitution( q(<) => q(&lt;),
                              q(>) => q(&gt;),
                              q(&) => q(&amp;) );
   $tabstop = $self->tabstop; # Text::Tabs
   $text    = $fmt->format_string( expand( $text ) );

   my $header_cells = sub {
      my ($c_max, $c_no) = @_; my $text = $self->loc( 'Source Code' );

      return $hacc->th( { class => $self->header_class }, $text );
   };
   my $row_cells = sub {
      my ($line, $r_no) = @_;

      my $class = $self->subtype.__column_class( 1 );
      my $cells = $hacc->td( { class => $class }, $line );

      return (1, $cells, $line);
   };

   return $self->_build_table( $text, $header_cells, $row_cells );
}

sub _render_text {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   $self->container( 1 ); $self->container_class( q(container textfile) );

   return $hacc->pre( $hacc->escape_html( $text, 0 ) );
}

# Private subroutines

sub __column_class {
   return __even_or_odd( $_[ 0 ] ).q(_col);
}

sub __even_or_odd {
   return ($_[ 0 ] + 1) % 2 == 0 ? q( even) : q( odd);
}

sub __row_class {
   return __even_or_odd( $_[ 0 ] ).q(_row);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
