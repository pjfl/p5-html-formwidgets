package HTML::FormWidgets::RadioGroup;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(columns labels values) );

sub init {
   my ($self, $args) = @_;

   $self->columns( undef );
   $self->labels(  undef );
   $self->values(  [] );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args)   = @_;

   $args->{columns}  = $self->columns  if ($self->columns);
   $args->{labels}   = $self->labels   if ($self->labels);
   $args->{onchange} = $self->onchange if ($self->onchange);
   $args->{values}   = $self->values;

   return $self->hacc->radio_group( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
