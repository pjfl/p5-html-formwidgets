package HTML::FormWidgets::File;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use IO::File;
use Readonly;
use Syntax::Highlight::Perl;
use Text::ParseWords;
use Text::Tabs;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(base header hide path root scheme select
                              style subtype) );

Readonly my %SCHEME =>
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

   $self->base(      q() );
   $self->container( 0 );
   $self->header(    [] );
   $self->hide(      [] );
   $self->path(      undef );
   $self->root(      undef );
   $self->scheme(    \%SCHEME );
   $self->select(    -1 );
   $self->style(     q() );
   $self->subtype(   q(file) );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   # Subtypes: file, csv, html, source, and logfile
   my ($self, $args) = @_;
   my ($attr, $box, $cells, $c_no, $fld, $fmt, $hacc, $key, $line);
   my ($pat, $path, $r_no, $rdr, $rows, $span, $text);

   $hacc = $self->hacc; $path = $self->path;

   if ($self->subtype eq q(html)) {
      $pat = $self->root;

      if ($path =~ m{ \A $pat }msx) {
         $path = $self->base.($path =~ s{ \A $pat }{/}msx);
      }

      $path  = $path =~ m{ \A http: }msx ? $path : $self->base.$path;
      $text  = 'border: 0px; bottom: 0px; position: absolute; ';
      $text .= 'top: 0px; width: 100%; height: 100%; '.$self->style;

      return $hacc->iframe( { src       => $path,
                              scrolling => q(auto),
                              style     => $text }, q(&nbsp;) );
   }

   return 'Not found '.$path   unless (-f $path);
   return 'Cannot read '.$path unless ($rdr = IO::File->new( $path, q(r) ));

   $text = do { local $RS = undef; <$rdr> }; $rdr->close();

   if ($self->subtype eq q(source)) {
      $fmt = Syntax::Highlight::Perl->new();
      $fmt->set_format( $self->scheme );
      $fmt->define_substitution( q(<) => q(&lt;),
                                 q(>) => q(&gt;),
                                 q(&) => q(&amp;) );
      $tabstop = $self->tabstop;
      $text    = $fmt->format_string( expand( $text ) );

      return $hacc->pre( { class => $self->subtype }, $text );
   }

   $r_no = 0; $rows = q(); $span = 1;

   if ($self->subtype eq q(logfile)) {
      # TODO: Add Prev and next links to append div
      for $line (split m { \n }mx, $text) {
         $line   = $hacc->escape_html( $line, 0 );
         $line   = $hacc->pre( { class => $self->subtype }, $line );
         $cells  = $hacc->td(  { class => $self->subtype }, $line );
         $rows  .= $hacc->tr(  { class => $self->subtype }, $cells )."\n";
         $r_no++;
      }

      push @{ $self->hide }, { name => q(nRows), value => $r_no };

      return $hacc->table( { cellpadding => 0, cellspacing => 0 }, $rows );
   }

   for $line (split m { \n }mx, $text) {
      $line  = $hacc->escape_html( $line, 0 );
      $cells = q(); $c_no = 0;

      if ($self->subtype eq q(csv)) {
         for $fld (parse_line( q(,), 0, $line )) {
            if ($r_no == 0 && $line =~ m{ \A \# }mx) {
               $fld = substr $fld, 1 if ($c_no == 0);

               unless ($self->header->[ $c_no ]) {
                  $self->header->[ $c_no ] = $fld;
               }
            }
            else {
               $attr   = { class => $self->subtype.q( ).($c_no % 2 == 0 ?
                                                         q(even) : q(odd)) };
               $cells .= $hacc->td( $attr, $fld );
            }

            $key = $fld if ($c_no == $self->select);
            $c_no++;
         }

         next if ($r_no == 0 && $line =~ m{ \A \# }msx);
      }
      else {
         $cells .= $hacc->td( { class => $self->subtype }, $line );
         $c_no++;
      }

      if ($self->select >= 0) {
         $box   = $hacc->checkbox( { label => q(),
                                     name  => q(select).$r_no,
                                     value => $key } );
         $cells = $hacc->td( { class => q(odd) }, $box ).$cells;
         $attr  = { class => q(lineNumber even) };
         $c_no++;
      }
      else { $attr = { class => q(lineNumber odd) } }

      $cells = $hacc->td( $attr, $r_no+1 ).$cells;
      $c_no++;

      $span  = $c_no if ($c_no > $span);
      $rows .= $hacc->tr( { class => $self->subtype }, $cells );
      $r_no++;
   }

   $cells = $hacc->th( { class => q(small table minimal) }, chr 35 );
   $c_no  = 1;

   if ($self->select >= 0) {
      $cells .= $hacc->th( { class => q(small table minimal) }, q(M) );
      $c_no++;
   }

   if ($self->subtype eq q(csv)) {
      if ($self->header->[0]) {
         for $text (@{ $self->header }) {
            $cells .= $hacc->th( { class => q(small table) }, $text );
            last if (++$c_no >= $span);
         }
      }
      else {
         for $text ('A' .. 'Z') {
            $cells .= $hacc->th( { class => q(small table) }, $text );
            last if (++$c_no >= $span);
         }
      }
   }
   else { $cells .= $hacc->th( { class => q(small table) }, 'Lines' ) }

   $rows  = $hacc->tr( $cells ).$rows;

   push @{ $self->hide }, { name  => q(nRows), value => $r_no };

   return $hacc->table( $rows );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
