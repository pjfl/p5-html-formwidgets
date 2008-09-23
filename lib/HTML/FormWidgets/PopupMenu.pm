package HTML::FormWidgets::PopupMenu;

# @(#)$Id$

use strict;
use warnings;
use base q(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(labels values) );

sub init {
   my ($self, $args) = @_;

   $self->labels( undef );
   $self->values( [] );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $ref)   = @_;

   $ref->{labels}   = $self->labels   if ($self->labels);
   $ref->{onchange} = $self->onchange if ($self->onchange);
   $ref->{values}   = $self->values;
   return $self->elem->popup_menu( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
