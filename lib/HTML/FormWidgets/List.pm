package HTML::FormWidgets::List;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( config data item_class ordered ) );

my $NBSP = '&#160;';

sub init {
   my ($self, $args) = @_;

   $self->config    ( {} );
   $self->class     ( 'plain' );
   $self->data      ( [] );
   $self->item_class( undef );
   $self->ordered   ( 0 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my ($data, $html);

   ($data = $self->data and $data->[ 0 ]) or return; my $js_args = {};

   if ($self->id) {
      for (grep { defined $self->config->{ $_ } } keys %{ $self->config }) {
         $js_args->{ $_ } = '"'.$self->config->{ $_ }.'"';
      }

      $self->add_literal_js( 'lists', $self->id, $js_args );
   }

   my $item_args = $self->item_class ? { class => $self->item_class } : {} ;

   for my $item (@{ $data }) {
      $html .= $hacc->li( $item_args,
                          $self->inflate( $item->{content} // $NBSP ) );
   }

   $args = { class => $self->class }; $self->id and $args->{id} = $self->id;

   $self->ordered and return $hacc->ol( $args, $html );

   return $hacc->ul( $args, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
