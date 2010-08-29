# @(#)$Id$

package HTML::FormWidgets::ScrollPin;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config) );

my $SPC = q( );
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->class( q(pintray) );
   $self->config( { pins   => q({ '.pintarget': { icon: 'scrollpin_icon' } }),
                    target => "'content'" } );
   $self->container( 0 );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $self->_js_config( 'scrollPins', $self->id, $self->config );
   $args = { class => $self->class, id => $self-> id };

   return $self->hacc->ul( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

