# @(#)$Id$

package HTML::FormWidgets::Flag;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

sub init {
   my ($self, $args) = @_;

   $self->container( 0 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   return $hacc->span( { class => q(flag_).$self->text }, q( ) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
