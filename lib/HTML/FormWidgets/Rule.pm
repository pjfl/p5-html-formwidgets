package HTML::FormWidgets::Rule;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($cells, $html); my $htag = $me->elem;

   $me->container( undef );

   if ($me->imgclass) {
      $html  = $htag->hr(  { class => $me->class } );
      $cells = $htag->td(  { class => q(minimal) }, $html );
      $html  = $htag->img( { alt   => $me->alt,
                             class => $me->imgclass,
                             src   => $me->text } );
   }
   else { $html = $me->text }

   $html = $htag->a( { href => $me->href }, $html ) if ($me->href);

   if ($me->tip) {
      $html = $htag->span( { class => q(tips), title => $me->tip }, $html );
      $me->tip( undef );
   }

   $cells .= $htag->td( { class => q(minimal) }, $html ) if ($html);
   $cells .= $htag->td( $htag->hr( { class => $me->class } ) );
   return $htag->table( { class => q(rule) }, $htag->tr( $cells ) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

