# @(#)$Id$

package HTML::FormWidgets::SidebarPanel;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.15.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config header panel) );

sub init {
   my ($self, $args) = @_;

   $self->class( q(accordion_content) );
   $self->config( {} );
   $self->container_class( q(accordion_panel_container) );
   $self->header( {} );
   $self->panel( {} );
   $self->sep( q() );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $header = $self->header;

   $self->add_literal_js( 'sidebars', $header->{id}, $self->config );

   $args    = { class => $header->{class}, id => $header->{id} };

   my $html = $hacc->div( $args, $header->{text} );

   $args    = { class => $self->class, id => $self->id };

   my $text = $hacc->div( $args, $self->text );

   $args    = { class => $self->panel->{class}, id => $self->panel->{id} };
   $html   .= $hacc->div( $args, $text );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
