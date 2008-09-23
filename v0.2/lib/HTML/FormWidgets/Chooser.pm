package HTML::FormWidgets::Chooser;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(button field height href js_obj key
                              screen_x screen_y width) );

sub init {
   my ($self, $args) = @_;

   $self->button(    q() );
   $self->container( 0 );
   $self->field(     q() );
   $self->height(    400 );
   $self->href(      undef );
   $self->js_obj(    q(submitObj.chooser) );
   $self->key(       q() );
   $self->screen_x(  10 );
   $self->screen_y(  10 );
   $self->width(     200 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my $onclick;

   $onclick  = 'return '.$self->js_obj;
   $onclick .= '(document.forms[0].'.$self->field.'.value, ';
   $onclick .= "document.forms[0], '".$self->key."', '".$self->href;
   $onclick .= "', 'width=".$self->width.', screenX='.$self->screen_x.', ';
   $onclick .= 'height='.$self->height.', screenY='.$self->screen_y;
   $onclick .= ", dependent=yes, titlebar=no, scrollbars=yes')";
   $args->{onclick} = $onclick;
   $args->{value  } = $self->button;

   return $self->elem->submit( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
