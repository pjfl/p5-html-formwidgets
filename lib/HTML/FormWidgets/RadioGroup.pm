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
   my ($self, $ref)   = @_;

   $ref->{columns}  = $self->columns  if ($self->columns);
   $ref->{labels}   = $self->labels   if ($self->labels);
   $ref->{onchange} = $self->onchange if ($self->onchange);
   $ref->{values}   = $self->values;
   return $self->elem->radio_group( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
