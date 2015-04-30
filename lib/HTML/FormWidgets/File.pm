package HTML::FormWidgets::File;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

use English qw( -no_match_vars );
use IO::File;
use PPI;
use PPI::HTML;
use Text::ParseWords;
use Text::Tabs;

__PACKAGE__->mk_accessors( qw( header header_class number
                               path select subtype tabstop ) );

my $HASH_CHAR = chr 35;

# Private functions
my $_even_or_odd = sub {
   return ($_[ 0 ] + 1) % 2 == 0 ? ' even' : ' odd';
};

my $_column_class = sub {
   return $_even_or_odd->( $_[ 0 ] ).'_col';
};

my $_row_class = sub {
   return $_even_or_odd->( $_[ 0 ] ).'_row';
};

# Private methods
my $_add_line_number = sub {
   my ($self, $r_no, $c_no) = @_;

   my $class = 'first lineNumber'.$_column_class->( $c_no );

   return $self->hacc->td( { class => $class }, $r_no + 1 );
};

my $_add_row_count = sub {
   my ($self, $n_rows) = @_;

   return $self->add_hidden( '_'.($self->name || q()).'_nrows', $n_rows );
};

my $_add_select_box = sub {
   my ($self, $r_no, $c_no, $val) = @_; my $hacc = $self->hacc;

   my $args  = { label => q(), name => $self->name.".select${r_no}",
                 value => $val };
   my $class = $self->subtype.$_column_class->( $c_no );

   return $hacc->td( { class => $class }, $hacc->checkbox( $args ) );
};

my $_build_table = sub {
   my ($self, $text, $header_cells, $row_cells) = @_; my $hacc = $self->hacc;

   my ($cells, $class, $val); my $r_no = 0; my $rows = q(); my $c_max = 1;

   for my $line (split m{ \n }mx, $text) {
      my $c_no = 0; my $lead = q();

      my ($ncells, $cells, $val) = $row_cells->( $line, $r_no );

      if ($cells) {
         $self->number and $lead = $self->$_add_line_number( $r_no, $c_no++ );
         $self->select >= 0
            and $lead .= $self->$_add_select_box( $r_no, $c_no++, $val );
         $class = $self->subtype.$_row_class->( $r_no );
         $rows .= $hacc->tr( { class => $class }, $lead.$cells );
         $r_no++;
      }

      $c_no += $ncells; $c_no > $c_max and $c_max = $c_no;
   }

   $class = $self->header_class.' minimal';
   $self->number
      and $cells = $hacc->th( { class => $class }, $self->loc( $HASH_CHAR ) );
   $self->select >= 0
      and $cells .= $hacc->th( { class => $class }, $self->loc( 'M' ) );
   $cells .= $header_cells->( $c_max, $self->select < 0 ? 1 : 2 );
   $rows   = $hacc->tr( $cells ).$rows;
   $self->$_add_row_count( $r_no );

   return $hacc->table( { cellspacing => 0, class => $self->subtype }, $rows );
};

sub _render_csv {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   my $header_cells = sub {
      my ($c_max, $c_no) = @_; my $cells = q();

      my @headers = $self->header->[ 0 ] ? @{ $self->header } : ('A' .. 'Z');

      for my $header (@headers) {
         $cells .= $hacc->th( { class => $self->header_class }, $header );
         ++$c_no >= $c_max and last;
      }

      return $cells;
   };
   my $row_cells = sub {
      my ($line, $r_no) = @_;

      my $cells = q(); my $f_no = 0; my $val = q();

      for my $fld (parse_line( ',', 0, $hacc->escape_html( $line, 0 ) )) {
         if ($r_no == 0 and $line =~ m{ \A \# }mx) {
            $f_no == 0 and $fld = substr $fld, 1;
            $self->header->[ $f_no ] = $fld;
         }
         else {
            my $class = $self->subtype
                       .$_column_class->( ($self->select < 0 ? 1 : 2) + $f_no );

            $cells .= $hacc->td( { class => $class }, $fld );
         }

         $f_no == $self->select and $val = $fld; $f_no++;
      }

      return ($f_no, $cells, $val);
   };

   return $self->$_build_table( $text, $header_cells, $row_cells );
}

sub _render_html {
   my ($self, $path) = @_;  my $hacc = $self->hacc;

   my $pat = $self->options->{root}; $self->container( 0 );

   $path  =~ m{ \A $pat }msx and $path =~ s{ \A $pat }{/}msx;

   return $hacc->iframe( { class     => $self->subtype,
                           src       => $self->uri_for( $path ),
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

      my $class = $self->subtype.$_column_class->( 1 );
      my $cells = $hacc->td( { class => $class }, $line );

      return (1, $cells, $line);
   };

   return $self->$_build_table( $text, $header_cells, $row_cells );
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

      my $class = $self->subtype.$_column_class->( 1 );
      my $cells = $hacc->td( { class => $class }, $line );

      return (1, $cells, $line);
   };

   return $self->$_build_table( $text, $header_cells, $row_cells );
}

sub _render_text {
   my ($self, $text) = @_; my $hacc = $self->hacc;

   $self->container_class( 'container textfile' );

   return $hacc->pre( $hacc->escape_html( $text, 0 ) );
}

# Public methods
sub init {
   my ($self, $args) = @_;

   $self->header      ( []       );
   $self->header_class( 'normal' );
   $self->number      ( 1        );
   $self->path        ( undef    );
   $self->select      ( -1       );
   $self->subtype     ( 'text'   );
   $self->tabstop     ( 3        );
   return;
}

sub render_field { # Subtypes: csv, html, logfile, source, and text
   my ($self, $args) = @_;

   my $path = $self->path or return $self->loc( 'Path not specified' );

   $self->subtype or return $self->loc( 'Subtype not specified' );
   $self->subtype eq 'html' and return $self->_render_html( $path );

   -f $path or return $self->loc( 'Path [_1] not found', $path );

   my $rdr    = IO::File->new( $path, 'r' )
      or return $self->loc( 'Path [_1] cannot open', $path );
   my $text   = do { local $RS = undef; <$rdr> }; $rdr->close;
   my $method = '_render_'.$self->subtype;

   return $self->$method( $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
