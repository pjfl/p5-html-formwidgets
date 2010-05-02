# @(#)$Id$

package HTML::FormWidgets::Button;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(assets button_name onclick src) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->assets(      q() );
   $self->class(       q(button) );
   $self->container(   0 );
   $self->button_name( q(_method) );
   $self->onclick(     q() );
   $self->src(         q() );
   $self->tiptype(     q(normal) );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $button;

   $args            = {};
   $args->{class  } = $self->class;
   $args->{name   } = $self->button_name;
   $args->{onclick} = $self->onclick if ($self->onclick);
   $args->{value  } = ucfirst $self->name;

   $self->src or return $self->hacc->submit( $args );

   $args->{alt} = ucfirst $self->name;
   $args->{src} = q(http:) eq (substr $self->src, 0, 5)
                ? $self->src : $self->assets.$self->src;
   return $self->hacc->image_button( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

