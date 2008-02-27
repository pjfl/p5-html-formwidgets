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

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

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

sub _render {
   # Subtypes: file, csv, html, source, and logfile
   my ($me, $ref) = @_;
   my ($attr, $box, $cells, $c_no, $fld, $fmt, $htag, $key, $line);
   my ($pat, $path, $r_no, $rdr, $rows, $span, $text);

   $me->header( [] )       unless (defined $me->header);
   $me->select( -1 )       unless (defined $me->select);
   $me->subtype( q(file) ) unless (defined $me->subtype);

   $htag = $me->elem; $path = $me->path;

   if ($me->subtype eq q(html)) {
      $pat   = $me->root;

      if ($path =~ m{ \A $pat }msx) {
         $path = $me->base.($path =~ s{ \A $pat }{/}msx);
      }

      $path  = $path =~ m{ \A http: }msx ? $path : $me->base.$path;
      $text  = 'border: 0px; bottom: 0px; position: absolute; ';
      $text .= 'top: 0px; width: 100%; '.$me->style;

      return $htag->iframe( { src       => $path,
                              scrolling => q(auto),
                              style     => $text }, q(&nbsp;) );
   }

   return 'Not found '.$path   unless (-f $path);
   return 'Cannot read '.$path unless ($rdr = IO::File->new( $path, q(r) ));

   $text = do { local $RS = undef; <$rdr> }; $rdr->close();

   if ($me->subtype eq q(source)) {
      $fmt = Syntax::Highlight::Perl->new();
      $fmt->set_format( \%SCHEME );
      $fmt->define_substitution( q(<) => q(&lt;),
                                 q(>) => q(&gt;),
                                 q(&) => q(&amp;) );
      $tabstop = 3;
      $text    = expand( $text );
      $text    = $fmt->format_string( $text );

      return $htag->pre( { class => $me->subtype }, $text );
   }

   $r_no = 0; $rows = q(); $span = 1;

   if ($me->subtype eq q(logfile)) {
      # TODO: Add Prev and next links to append div
      for $line (split m { \n }mx, $text) {
         $line   = $htag->escape_html( $line, 0 );
         $line   = $htag->pre( { class => $me->subtype }, $line );
         $cells  = $htag->td(  { class => $me->subtype }, $line );
         $rows  .= $htag->tr(  { class => $me->subtype }, $cells )."\n";
         $r_no++;
      }

      $text = $htag->hidden( { name => q(nRows), value => $r_no } );
      push @{ $me->hide }, $text;

      return $htag->table( { cellpadding => 0, cellspacing => 0 }, $rows );
   }

   for $line (split m { \n }mx, $text) {
      $line  = $htag->escape_html( $line, 0 );
      $cells = q(); $c_no = 0;

      if ($me->subtype eq q(csv)) {
         for $fld (parse_line( q(,), 0, $line )) {
            if ($r_no == 0 && $line =~ m{ \A \# }mx) {
               $fld = substr $fld, 1 if ($c_no == 0);
               $me->header->[ $c_no ] = $fld unless ($me->header->[ $c_no ]);
            }
            else {
               $attr   = { class => $me->subtype.q( ).($c_no % 2 == 0 ?
                                                      q(even) : q(odd)) };
               $cells .= $htag->td( $attr, $fld );
            }

            $key = $fld if ($c_no == $me->select);
            $c_no++;
         }

         next if ($r_no == 0 && $line =~ m{ \A \# }msx);
      }
      else {
         $cells .= $htag->td( { class => $me->subtype }, $line );
         $c_no++;
      }

      if ($me->select >= 0) {
         $box   = $htag->checkbox( { label => q(),
                                     name  => q(select).$r_no,
                                     value => $key } );
         $cells = $htag->td( { class => q(odd) }, $box ).$cells;
         $attr  = { class => q(lineNumber even) };
         $c_no++;
      }
      else { $attr = { class => q(lineNumber odd) } }

      $cells = $htag->td( $attr, $r_no+1 ).$cells;
      $c_no++;

      $span  = $c_no if ($c_no > $span);
      $rows .= $htag->tr( { class => $me->subtype }, $cells );
      $r_no++;
   }

   $cells = $htag->th( { class => q(small table minimal) }, chr 35 );
   $c_no  = 1;

   if ($me->select >= 0) {
      $cells .= $htag->th( { class => q(small table minimal) }, q(M) );
      $c_no++;
   }

   if ($me->subtype eq q(csv)) {
      if ($me->header->[0]) {
         for $text (@{ $me->header }) {
            $cells .= $htag->th( { class => q(small table) }, $text );
            last if (++$c_no >= $span);
         }
      }
      else {
         for $text ('A' .. 'Z') {
            $cells .= $htag->th( { class => q(small table) }, $text );
            last if (++$c_no >= $span);
         }
      }
   }
   else { $cells .= $htag->th( { class => q(small table) }, 'Lines' ) }

   $rows  = $htag->tr( $cells ).$rows;

   push @{ $me->hide }, $htag->hidden( { name => q(nRows), value => $r_no } );

   return $htag->table( $rows );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
