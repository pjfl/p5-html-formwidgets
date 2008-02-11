package HTML::FormWidgets::File;

# @(#)$Id: File.pm 236 2007-11-26 19:59:28Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use Readonly;
use Syntax::Highlight::Perl;
use Text::ParseWords;
use Text::Tabs;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 236 $ =~ /\d+/gmx );

Readonly my %SCHEME =>
   ( Variable_Scalar   => ['<font color="#CC6600">', '</font>'],
     Variable_Array    => ['<font color="#FFCC00">', '</font>'],
     Variable_Hash     => ['<font color="#990099">', '</font>'],
     Variable_Typeglob => ['<font color="#000000">', '</font>'],
     Subroutine        => ['<font color="#339933">', '</font>'],
     Quote             => ['<font color="#000000">', '</font>'],
     String            => ['<font color="#3399FF">', '</font>'],
     Comment_Normal    => ['<font color="#ff0000"><i>', '</i></font>'],
     Comment_POD       => ['<font color="#ff9999">', '</font>'],
     Bareword          => ['<font color="#000000">', '</font>'],
     Package           => ['<font color="#000000">', '</font>'],
     Number            => ['<font color="#003333">', '</font>'],
     Operator          => ['<font color="#999999">', '</font>'],
     Symbol            => ['<font color="#000000">', '</font>'],
     Keyword           => ['<font color="#0000ff"><b>', '</b></font>'],
     Builtin_Operator  => ['<font color="#000000">', '</font>'],
     Builtin_Function  => ['<font color="#000000">', '</font>'],
     Character         => ['<font color="#3399FF"><b>', '</b></font>'],
     Directive         => ['<font color="#000000"><i><b>',
                           '</b></i></font>'],
     Label             => ['<font color="#000000">', '</font>'],
     Line              => ['<font color="#000000">', '</font>'], );

sub _render {
   # Subtypes: file, csv, html, source, and logfile
   my ($me, $ref) = @_;
   my ($attr, $box, $cells, $cNo, $elem, $fld, $fmt, $key, $line, $npages);
   my ($pat, $path, @printers, $rdr, $rNo, $rows, $span, $text);

   $me->header( [] )      unless (defined $me->header);
   $me->select( -1 )      unless (defined $me->select);
   $me->subtype( 'file' ) unless (defined $me->subtype);

   $elem = $me->elem; $path = $me->path;

   if ($me->footer and $me->footer->{left}) {
      $me->footer->{left} = $me->_getFooter();
   }

   if ($me->subtype eq 'html') {
      $pat   = $me->root;

      if ($path =~ m{ \A $pat }msx) {
         $path = $me->base.($path =~ s{ \A $pat }{ / }msx);
      }

      $path  = $path =~ m{ \A http: }msx ? $path : $me->webserver.$path;
      $path  = $path =~ m{ \A http: }msx ? $path : $me->base.$path;
      $text  = 'border: 0px; bottom: 0px; position: absolute; ';
      $text .= 'top: 0px; width: 100%; '.$me->style;

      return $elem->iframe( { src       => $path,
                              scrolling => 'auto',
                              style     => $text }, '&nbsp;' );
   }

   return 'Not found '.$path   unless (-f $path);
   return 'Cannot read '.$path unless ($rdr = IO::File->new( $path, 'r' ));

   $text = do { local $RS = undef; <$rdr> }; $rdr->close();

   if ($me->subtype eq 'source') {
      $fmt  = Syntax::Highlight::Perl->new();
      $fmt->set_format( \%SCHEME );
      $fmt->define_substitution( q(<) => '&lt;',
                                 q(>) => '&gt;',
                                 q(&) => '&amp;' );
      $tabstop = 3;
      $text    = expand( $text );
      $text    = $fmt->format_string( $text );

      return $elem->pre( { class => 'source'}, $text );
   }

   $rNo = 0; $rows = ''; $span = 1;

   if ($me->subtype eq 'logfile') {
      # TODO: Add Prev and next links to append div
      for $line (split m { \n }mx, $text) {
         $line   = $elem->pre( $elem->escape_html( $line, 0 ) );
         $cells  = $elem->td( { class => $me->subtype }, $line );
         $rows  .= $elem->tr( { class => $me->subtype }, $cells );
         $rNo++;
      }

      push @{ $me->hide }, $elem->hidden( { name => 'nRows', value => $rNo });

      return $elem->table( { cellpadding => 0, cellspacing => 0 }, $rows );
   }

   for $line (split m { \n }mx, $text) {
      $line  = $elem->escape_html( $line, 0 );
      $cells = ''; $cNo = 0;

      if ($me->subtype eq 'csv') {
         for $fld (parse_line( q(,), 0, $line )) {
            if ($rNo == 0 && $line =~ m{ \A \# }mx) {
               $fld = substr $fld, 1 if ($cNo == 0);
               $me->header->[ $cNo ] = $fld unless ($me->header->[ $cNo ]);
            }
            else {
               $attr   = { class => $me->subtype.' '.($cNo % 2 == 0 ?
                                                      'even' : 'odd') };
               $cells .= $elem->td( $attr, $fld );
            }

            $key = $fld if ($cNo == $me->select);
            $cNo++;
         }

         next if ($rNo == 0 && $line =~ m{ \A \# }msx);
      }
      else {
         $cells .= $elem->td( { class => $me->subtype }, $line );
         $cNo++;
      }

      if ($me->select >= 0) {
         $box   = $elem->checkbox( { label => '', name => 'select'.$rNo,
                                     value => $key } );
         $cells = $elem->td( { class => 'odd' }, $box ).$cells;
         $attr  = { class => 'lineNumber even' };
         $cNo++;
      }
      else { $attr = { class => 'lineNumber odd' } }

      $cells = $elem->td( $attr, $rNo+1 ).$cells;
      $cNo++;

      $span  = $cNo if ($cNo > $span);
      $rows .= $elem->tr( { class => $me->subtype }, $cells );
      $rNo++;
   }

   $cells = $elem->th( { class => 'small table minimal' }, chr 35 );
   $cNo   = 1;

   if ($me->select >= 0) {
      $cells .= $elem->th( { class => 'small table minimal' }, 'M' );
      $cNo++;
   }

   if ($me->subtype eq 'csv') {
      if ($me->header->[0]) {
         for $text (@{ $me->header }) {
            $cells .= $elem->th( { class => 'small table' }, $text );
            last if (++$cNo >= $span);
         }
      }
      else {
         for $text ('A' .. 'Z') {
            $cells .= $elem->th( { class => 'small table' }, $text );
            last if (++$cNo >= $span);
         }
      }
   }
   else { $cells .= $elem->th( { class => 'small table' }, 'Lines' ) }

   $rows  = $elem->tr( $cells ).$rows;

   push @{ $me->hide }, $elem->hidden( { name => 'nRows', value => $rNo } );

   return $elem->table( $rows );
}

sub _getFooter {
   my ($me) = @_; my ($npages, @printers, $text);

   return if ($me->footer->{left} ne 'printer_controls');
# Should have stashed this sooner
   @printers = (qw(a b));
#     @printers = @{PM::Model::File::Printers->retrieve()->printers};
   $npages   = ($me->npages ? $me->npages : 1);
#     $me->hide->[-1] = hidden({ name => 'pathName', value => $path });
   $text  = 'Page&nbsp;';
   $text .= $me->elem->textfield({ default => '1',
                                   name    => 'fromPage', size => '3'});
   $text .= '&nbsp;to&nbsp;';
   $text .= $me->elem->textfield({ default => $npages,
                                   name    => 'toPage', size => '3'});
   $text .= '&nbsp;Select printer&nbsp;';
   $text .= $me->elem->popup_menu({ name   => 'printer',
                                    values => \@printers });
   $text .= '&nbsp;'.$me->elem->submit({ name  => 'button',
                                         value => 'Print' });
   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
