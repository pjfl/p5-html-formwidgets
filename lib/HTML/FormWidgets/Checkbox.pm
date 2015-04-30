package HTML::FormWidgets::Checkbox;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( checked label_class labels value ) );

sub init {
   my ($self, $args) = @_;

   $self->checked    ( 0  );
   $self->label_class( 'checkbox_label' );
   $self->labels     ( {} );
   $self->value      ( 1  );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $self->checked and $args->{checked} = $self->is_xml ? 'checked' : undef;
   $args->{value} = $self->value;

   my $html = $hacc->checkbox( $args );

   my $label; exists $self->labels->{ $self->value }
      and   $label = $self->labels->{ $self->value };

   $label and $html .= $hacc->span( { class => $self->label_class }, $label );

   return $hacc->div( { class => 'checkbox_container' }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
