# @(#)$Ident: Checkbox.pm 2013-05-16 14:22 pjf ;

package HTML::FormWidgets::Checkbox;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.19.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(checked label_class labels value) );

sub init {
   my ($self, $args) = @_;

   $self->checked    ( 0 );
   $self->label_class( q(checkbox_label) );
   $self->labels     ( {} );
   $self->value      ( 1 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $self->checked and $args->{checked} = $self->is_xml ? q(checked) : undef;
   $args->{value} = $self->value;

   my $html  = $hacc->checkbox( $args );
   my $label = exists $self->labels->{ $self->value }
                    ? $self->labels->{ $self->value } : undef;

   $label and $html .= $hacc->span( { class => $self->label_class }, $label );

   return $hacc->div( { class => q(checkbox_container) }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
