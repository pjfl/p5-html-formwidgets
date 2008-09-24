package HTML::FormWidgets::ScrollingList;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(height labels values) );

sub init {
   my ($self, $args) = @_;

   $self->height( 10 );
   $self->labels( undef );
   $self->values( [] );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_;

   $args->{labels}   = $self->labels   if ($self->labels);
   $args->{onchange} = $self->onchange if ($self->onchange);
   $args->{size}     = $self->height;
   $args->{values}   = $self->values;

   return $self->hacc->scrolling_list( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
