# @(#)$Id$

package HTML::FormWidgets::Textarea;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(height width) );

sub init {
   my ($self, $args) = @_;

   $self->height( 5  );
   $self->width ( 60 );
   return;
}

sub render_field {
   my ($self, $args)  = @_;

   $args->{class} .= q( ifield);
   $args->{cols }  = $self->width;
   $args->{rows }  = $self->height;

   return $self->hacc->textarea( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
