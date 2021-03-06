package HTML::FormWidgets::TabSwapper;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( data ) );

sub init {
   my ($self, $args) = @_;

   $self->class    ( 'tabswapper' );
   $self->container( 0            );
   $self->data     ( []           );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   for my $item (@{ $self->data }) {
      my $clicker = $self->inflate( $item->{clicker} );
      my $section = $self->inflate( $item->{section} );

      $html   .= $hacc->dt ( { class => 'tab off'       }, $clicker );
      $section = $hacc->div( { class => 'panel_content' }, $section );
      $html   .= $hacc->dd ( { class => 'panel'         }, $section );
   }

   $html = $hacc->dl( { class => 'tabset' }, $html );

   return $hacc->div( { class => $self->class, id => $self->id }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
