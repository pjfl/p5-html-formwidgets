package HTML::FormWidgets::Textarea;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(height width) );

sub init {
   my ($self, $args) = @_;

   $self->height( 5);
   $self->width(  60 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $ref)  = @_;

   $ref->{cols} = $self->width;
   $ref->{rows} = $self->height;

   return $self->elem->textarea( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
