package HTML::FormWidgets::Anchor;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)  = @_;

   delete $ref->{name};
   $ref->{class  } = $me->class || q(linkFade);
   $ref->{href   } = $me->href  || q();
   $ref->{onclick} = $me->onclick if ($me->onclick);

   return $me->elem->a( $ref, $me->text || q(link) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

