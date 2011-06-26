# @(#)$Id$

package HTML::FormWidgets::Checkbox;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
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
   my ($self, $args) = @_;

   $args->{checked} = $self->is_xml ? q(checked) : undef if ($self->checked);
   $args->{value  } = $self->value;

   my $html  = $self->hacc->checkbox( $args );
   my $label = exists $self->labels->{ $self->value }
                    ? $self->labels->{ $self->value } : undef;

   $label
      and $html .= $self->hacc->span( { class => $self->label_class }, $label );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
