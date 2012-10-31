# @(#)$Id$

package HTML::FormWidgets::Image;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.17.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(fhelp subtype) );

sub init {
   my ($self, $args) = @_;

   $self->fhelp  ( q()       );
   $self->subtype( q(normal) );
   $self->tiptype( q(normal) );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $args = { alt => $self->fhelp, src => $self->text };

   $self->class and $args->{class} = $self->class;
   $self->id    and $args->{id   } = $self->id;

   $self->subtype eq q(icon) and return $hacc->span( $args );

   return $hacc->img( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
