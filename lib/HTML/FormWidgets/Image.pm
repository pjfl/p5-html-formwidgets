package HTML::FormWidgets::Image;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(fhelp) );

sub _init {
   my ($self, $args) = @_;

   $self->fhelp(   q() );
   $self->tiptype( q(normal) );
   return;
}

sub _render {
   my ($self, $args) = @_;

   return $self->hacc->img( { alt   => $self->fhelp,
                              class => $self->class,
                              src   => $self->text } );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
