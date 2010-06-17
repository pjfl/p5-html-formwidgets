# @(#)$Id$

package HTML::FormWidgets::Chooser;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config field href) );

sub init {
   my ($self, $args) = @_;

   $self->class  ( q(button chooser_button fade) );
   $self->config ( { height   => 500, screen_x => 10,
                     screen_y => 10,  width    => 500 } );
   $self->default( q(Choose) );
   $self->field  ( q() );
   $self->href   ( undef );
   return;
}

sub render_field {
   my $self = shift;
   my $html = $self->hacc->submit( { class => $self->class,
                                     id    => $self->id,
                                     name  => q(_method),
                                     value => $self->default } );

   $self->config->{field} = '"'.$self->field.'"';
   $self->config->{href } = '"'.$self->href.'"';

   $html .= $self->_js_config( 'submit', $self->id, $self->config );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
