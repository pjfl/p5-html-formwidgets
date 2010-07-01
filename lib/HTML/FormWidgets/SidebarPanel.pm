# @(#)$Id$

package HTML::FormWidgets::SidebarPanel;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config header panel) );

sub init {
   my ($self, $args) = @_;

   $self->class( q(sidebarContent) );
   $self->config( {} );
   $self->container_class( q(accordion_panel_container) );
   $self->header( {} );
   $self->panel( {} );
   $self->sep( q() );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $args  = { class => $self->header->{class}, id => $self->header->{id} };

   my $html = $hacc->div( $args, $self->header->{text} );

   $args  = { class => $self->class, id => $self->id };

   my $text = $hacc->div( $args, $self->text );

   $args  = { class => $self->panel->{class}, id => $self->panel->{id} };
   $html .= $hacc->div( $args, $text );
   $html .= $self->_js_config( 'sidebars', $self->header->{id}, $self->config );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
