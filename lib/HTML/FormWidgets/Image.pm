# @(#)$Id$

package HTML::FormWidgets::Image;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(fhelp) );

sub init {
   my ($self, $args) = @_;

   $self->fhelp  ( q()       );
   $self->tiptype( q(normal) );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $args = { alt => $self->fhelp, src => $self->text };

   $self->class and $args->{class} = $self->class;
   $self->id    and $args->{id   } = $self->id;

   return $self->hacc->img( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
