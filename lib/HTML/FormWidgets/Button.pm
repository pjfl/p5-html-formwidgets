# @(#)$Id$

package HTML::FormWidgets::Button;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(assets button_name config src) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->assets     ( q()        );
   $self->button_name( q(_method) );
   $self->class      ( q(button)  );
   $self->config     ( {}         );
   $self->container  ( 0          );
   $self->src        ( q()        );
   $self->tiptype    ( q(normal)  );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $html;

   $args          = {};
   $args->{class} = $self->class;
   $args->{id   } = $self->id;
   $args->{name } = $self->button_name;
   $args->{value} = ucfirst $self->name;

   if ($self->src) {
      $args->{alt} = ucfirst $self->name;
      $args->{src} = q(http:) eq (substr $self->src, 0, 5)
                   ? $self->src : $self->assets.$self->src;
      $html = $self->hacc->image_button( $args );
   }
   else { $html = $self->hacc->submit( $args ) }

   keys %{ $self->config } > 0
      and $html .= $self->_js_config( 'anchors', $self->id, $self->config );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

