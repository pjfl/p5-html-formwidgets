# @(#)$Id$

package HTML::FormWidgets::Label;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(dropcap) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0   );
   $self->dropcap  ( 0   );
   $self->text     ( q() );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $text = $self->text;

   ($text ||= $self->loc( $self->name ) || q()) =~ s{ \A \n }{}msx;
   $text or return;

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

   $self->class or return $text;

   return $self->hacc->span( { class => $self->class }, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
