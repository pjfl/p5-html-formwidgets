package HTML::FormWidgets::Image;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( fhelp subtype ) );

sub init {
   my ($self, $args) = @_;

   $self->fhelp  ( q()       );
   $self->subtype( q(normal) );
   $self->tiptype( q(normal) );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $src = 'http:' eq (substr $self->text, 0, 5)
           ? $self->text : ($self->options->{assets} // q()).$self->text;

   $args = { alt => $self->fhelp, src => $src };

   $self->class and $args->{class} = $self->class;
   $self->id    and $args->{id   } = $self->id;

   $self->subtype eq 'icon' and return $hacc->span( $args );

   return $hacc->img( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
