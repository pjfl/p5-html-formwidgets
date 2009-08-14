package HTML::FormWidgets::Label;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(dropcap markdown) );

sub _init {
   my ($self, $args) = @_;

   $self->container( 0 );
   $self->dropcap(   0 );
   $self->markdown(  0 );
   $self->text(      q() );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($markup, $text);

   $text    = $self->text;
   ($text ||= $self->loc( $self->name ) || q()) =~ s{ \A \n }{}msx;
   $text    = $self->text_obj->markdown( $text ) if ($text && $self->markdown);

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
