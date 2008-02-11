package HTML::FormWidgets::Anchor;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

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

