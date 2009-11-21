package HTML::FormWidgets::Anchor;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(anchor_class fhelp href imgclass onclick) );

sub _init {
   my ($self, $args) = @_;

   $self->anchor_class   ( q(anchor_fade) );
   $self->container_class( q(label_text)  );
   $self->fhelp          ( q()            );
   $self->href           ( undef          );
   $self->imgclass       ( undef          );
   $self->onclick        ( undef          );
   $self->text           ( q(link)        );
   $self->tiptype        ( q(normal)      );
   return;
}

sub _render {
   my ($self, $args) = @_;

   if ($self->imgclass) {
      $self->text( $self->hacc->img( { alt   => $self->fhelp,
                                       class => $self->imgclass,
                                       src   => $self->text } ) );
   }

   if ($self->href) {
      delete $args->{name};
      $args->{href   } = $self->href;
      $args->{class  } = $self->anchor_class;
      $args->{onclick} = $self->onclick if ($self->onclick);

      return $self->hacc->a( $args, $self->text );
   }

   return $self->text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

