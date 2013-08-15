# @(#)$Ident: TableRow.pm 2013-05-16 14:20 pjf ;

package HTML::FormWidgets::TableRow;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.20.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(classes fields values) );

sub init {
   my ($self, $args) = @_;

   $self->class    ( q() );
   $self->classes  ( {}  );
   $self->container( 0   );
   $self->fields   ( []  );
   $self->values   ( {}  );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $cells;

   for my $field (@{ $self->fields }) {
      my $class   = $self->classes->{ $field } || q();
      my $content = $self->inflate( $self->values->{ $field } || q() );

      $cells .= $hacc->td( { class => $class }, $content );
   }

   return $hacc->tr( { class => $self->class }, $cells );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
