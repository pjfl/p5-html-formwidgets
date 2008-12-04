package HTML::FormWidgets::ImageButton;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(assets button_name onclick src) );

my $SEP = q(/);
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->assets(      q() );
   $self->class(       q(button) );
   $self->container(   0 );
   $self->button_name( q(_method) );
   $self->onclick(     q(window.submit) );
   $self->src(         q() );
   $self->tiptype(     q(normal) );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my $button;

   $args            = {};
   $args->{class  } = $self->class;
   $args->{name   } = $self->button_name;
   $args->{onclick} = $self->onclick;
   $args->{value  } = ucfirst $self->name;

   return $self->hacc->submit( $args ) unless ($self->src);

   $args->{alt} = ucfirst $self->name;
   $args->{src} = $SEP eq (substr $self->src, 0, 1)
                ? $self->src : $self->assets.$self->src;
   return $self->hacc->image_button( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

