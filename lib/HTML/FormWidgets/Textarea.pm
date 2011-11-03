# @(#)$Id$

package HTML::FormWidgets::Textarea;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

sub render_field {
   my ($self, $args)  = @_;

   $args->{class} .= q( ifield).($self->class ? q( ).$self->class : q());

   return $self->hacc->textarea( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
