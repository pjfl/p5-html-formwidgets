# @(#)$Id$

package HTML::FormWidgets::Label;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(dropcap) );

sub init {
   my ($self, $args) = @_;

   $self->class    ( q(label_text) );
   $self->container( 0   );
   $self->dropcap  ( 0   );
   $self->text     ( q() );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $text = $self->text or return;

   ($text = $self->loc( $self->text )) =~ s{ \A \n }{}msx;

   if ($self->dropcap) {
      my $markup;

      if ($text =~ m{ \A (\<[A-Za-z0-9]+\>) }mx) {
         $markup  = $1;
         $markup .= $self->hacc->span( { class => q(dropcap) },
                                       substr $text, length $1, 1 );
         $markup .= substr $text, (length $1) + 1;
      }
      else {
         $markup  = $self->hacc->span( { class => q(dropcap) },
                                       substr $text, 0, 1 );
         $markup .= substr $text, 1;
      }

      $text = $markup;
   }

   $args = { class => $self->class }; $self->id and $args->{id} = $self->id;

   return $self->hacc->span( $args, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
