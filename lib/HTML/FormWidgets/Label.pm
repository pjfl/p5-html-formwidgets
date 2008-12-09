package HTML::FormWidgets::Label;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(dropcap) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0 );
   $self->dropcap(   0 );
   $self->text(      q() );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($markup, $text);

   ($text = $self->text || $self->msg( $self->name )) =~ s{ \A \n }{}msx;

   return unless ($text);

   if ($self->dropcap) {
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

   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
