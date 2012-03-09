# @(#)$Id$

package HTML::FormWidgets::Menu;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(data select spacer) );

my $NBSP = '&#160;';

sub init {
   my ($self, $args) = @_;

   $self->container( 0   );
   $self->data     ( []  );
   $self->select   ( 0   );
   $self->spacer   ( q() );
   return;
}

sub render_field {
   my ($self, $args) = @_; my ($content, $data, $html, $text);

   my $hacc = $self->hacc;

   unless ($data = $self->data and $data->[ 0 ]) {
      $html  = $hacc->span( { class => q(menu_pad)    }, $NBSP );
      $html .= $hacc->span( { class => q(menu_filler) }, $NBSP );

      return $html;
   }

   my $selected = $data->[ 0 ]->{selected} || -1;

   for my $index (0 .. $#{ $data }) {
      if ($self->spacer and $index > 0) {
         $text  = $hacc->span( { class => q(menu_pad)    }, $NBSP );
         $text .= $hacc->span( { class => q(menu_filler) }, $self->spacer );
         $html .= $hacc->li  ( $text );
      }

      $text    = $self->select && $index == $selected
               ? $hacc->span( { class => q(menu_top) }, $NBSP )
               : $hacc->span( { class => q(menu_pad) }, $NBSP );

      unless ($content = $data->[ $index ]->{items}->[ 0 ]->{content}) {
         $text .= $hacc->span( { class => q(menu_filler) }, $NBSP );
         $html .= $hacc->li( $text );
         next;
      }

      $text   .= $self->inflate( $content );

      my $count = 0; my $dlist = q();

      for my $item (@{ $data->[ $index ]->{items} }) {
         $dlist .= $count < 1
                 ? $hacc->dt()
                 : $hacc->dd( $self->inflate( $item->{content} ) );
         $count++;
      }

      $count > 1 and $dlist
         .= $hacc->dd( $hacc->span( { class => q(menu_bottom) }, $NBSP ) );

      $html  .= $hacc->li( $text.$hacc->dl( $dlist ) );
   }

   return $hacc->ul( { class => q(menu), id => $args->{id} }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
