package HTML::FormWidgets::Label;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($markup, $text);

   $ref->{class} = q(label) unless ($me->class);

   ($text = $me->msg( $me->name ) || $me->text || q()) =~ s{ \A \n }{}msx;

   if ($text && $me->dropcap) {
      if ($text =~ m{ \A (\<[A-Za-z0-9]+\>) }mx) {
         $markup  = $1;
         $markup .= $me->elem->span( { class => q(dropcap) },
                                     substr $text, length $1, 1 );
         $markup .= substr $text, (length $1) + 1;
      }
      else {
         $markup  = $me->elem->span( { class => q(dropcap) },
                                     substr $text, 0, 1 );
         $markup .= substr $text, 1;
      }

      $text = $markup;
   }

   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
