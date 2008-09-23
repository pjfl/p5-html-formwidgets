package HTML::FormWidgets::ImageButton;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(assets) );

sub init {
   my ($self, $args) = @_;

   $self->assets( q() );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my $text;

   $args            = {};
   $args->{class  } = q(button);
   $args->{name   } = q(_verb);
   $args->{onclick} = 'submit()';
   $args->{src    } = $self->assets.$self->name.'.png';
   $args->{value  } = ucfirst $self->name;
   $text            = $self->elem->image_button( $args );
   $args            = { class => q(help tips), title => $self->tip };
   $self->tip( undef );
   return $self->elem->span( $args, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

