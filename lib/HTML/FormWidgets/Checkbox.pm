package HTML::FormWidgets::Checkbox;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(checked label_class labels value) );

sub init {
   my ($self, $args) = @_;

   $self->checked(     0 );
   $self->label_class( q(note) );
   $self->labels(      {} );
   $self->value(       1 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args)  = @_;

   $args->{checked} = q(checked) if ($self->checked);
   $args->{value  } = $self->value;

   my $html  = $self->hacc->checkbox( $args );
   my $label = exists $self->labels->{ $self->value }
                    ? $self->labels->{ $self->value } : undef;

   if ($label) {
      $html .= $self->hacc->span( { class => $self->label_class }, $label );
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
