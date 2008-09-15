package HTML::FormWidgets::Anchor;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref)  = @_;

   delete $ref->{name};
   $ref->{class  } = $self->class || q(linkFade);
   $ref->{href   } = $self->href  || q();
   $ref->{onclick} = $self->onclick if ($self->onclick);

   return $self->elem->a( $ref, $self->text || q(link) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

