package HTML::FormWidgets::Anchor;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(href onclick) );

sub init {
   my ($self, $args) = @_;

   $self->class(   $self->class || q(linkFade) );
   $self->href(    q() );
   $self->onclick( undef );
   $self->text(    q(link) );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_;

   delete $args->{name};
   $args->{class  } = $self->class;
   $args->{href   } = $self->href;
   $args->{onclick} = $self->onclick if ($self->onclick);

   return $self->hacc->a( $args, $self->text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

