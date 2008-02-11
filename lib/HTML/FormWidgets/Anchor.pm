package HTML::FormWidgets::Anchor;

# @(#)$Id: Anchor.pm 141 2007-08-13 04:41:37Z PFlanigan $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 141 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)  = @_;

   return $me->elem->a( { class => $me->class || 'linkFade',
                          href  => $me->href }, $me->text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

