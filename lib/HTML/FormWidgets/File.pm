# @(#)$Ident: File.pm 2013-05-16 14:22 pjf ;

package HTML::FormWidgets::File;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.19.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);
use IO::File;
use PPI;
use PPI::HTML;
use Text::ParseWords;
use Text::Tabs;

__PACKAGE__->mk_accessors( qw(header header_class number
                              path select subtype tabstop) );

my $HASH_CHAR = chr 35;

sub init {
   my ($self, $args) = @_;

   $self->header      ( []        );
   $self->header_class( q(normal) );
   $self->number      ( 1         );
   $self->path        ( undef     );
   $self->select      ( -1        );
   $self->subtype     ( q(text)   );
   $self->tabstop     ( 3         );
   return;
}

sub render_field { # Subtypes: csv, html, logfile, source, and text
   my ($self, $args) = @_;

   my $path = $self->path or return $self->loc( 'Path not specified' );

   $self->subtype or return $self->loc( 'Subtype not specified' );
   $self->subtype eq q(html) and return $self->_render_html( $path );

   -f $path or return $self->loc( 'Path [_1] not found', $path );

   my $error  = $self->loc( 'Path [_1] cannot read', $path );
   my $rdr    = IO::File->new( $path, q(r) ) or return $error;
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

   return $self->add_hidden( q(_).($self->name || q()).q(_nrows), $n_rows );
}

sub _add_select_box {
   my ($self, $r_no, $c_no, $val) = @_; my $hacc = $self->hacc;

   my $args  = { label => q(), name => $self->name.".select${r_no}",
                 value => $val };
   my $class = $self->subtype.__column_class( $c_no );

   return $hacc->td( { class => $class }, $hacc->checkbox( $args ) );
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

   my $pat = $self->options->{root}; $self->container( 0 );

   $path  =~ m{ \A $pat }msx
      and $path = $self->options->{base}.($path =~ s{ \A $pat }{/}msx);
   $path  = $path =~ m{ \A http: }msx ? $path : $self->options->{base}.$path;

   return $hacc->iframe( { class     => $self->subtype,
                           src       => $path,
                           scrolling => q(auto) }, '&#160;' );
}

sub _render_logfile {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   my $r_no = 0; my $rows = q(); my $cells; $self->container( 0 );

   # TODO: Add Prev and next links to append div. Interior log file sequences
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
   my ($self, $text) = @_; my $hacc = $self->hacc; $self->container( 0 );

   $tabstop = $self->tabstop; $text = expand( $text ); # Text::Tabs

   my $document  = PPI::Document->new( \$text );
   my $highlight = PPI::HTML->new( line_numbers => 1 );
   my @lines     = split m{ <br>\n }msx, $highlight->html( $document );

   for my $lno (0 .. $#lines) {
      $lines[ $lno ] =~ s{ \A </span> }{}msx and $lines[ $lno-1 ] .= q(</span>);
      $lines[ $lno ] =~ s{ <span\s+class="line_number">\s*\d+:\s+</span> }{}msx;
   }

   $text = join "\n", @lines;

   my $header_cells = sub {
      my ($c_max, $c_no) = @_; my $heading = $self->loc( 'Source Code' );

      return $hacc->th( { class => $self->header_class }, $heading );
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

   $self->container_class( q(container textfile) );

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
