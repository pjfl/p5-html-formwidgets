package HTML::FormWidgets::Hidden;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

sub init {
   my ($self, $args) = @_;

   $self->container(  0 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_;

   delete $args->{id};
   $args->{type}  = q(hidden);
   $args->{value} = delete $args->{default};

   return $self->hacc->input( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

