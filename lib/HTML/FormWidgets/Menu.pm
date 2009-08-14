package HTML::FormWidgets::Menu;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(data select spacer) );

my $NBSP = q(&nbsp;);

sub _init {
   my ($self, $args) = @_;

   $self->container( 0   );
   $self->data     ( []  );
   $self->select   ( 0   );
   $self->spacer   ( q() );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($content, $data, $fill, $html, $text);

   my $hacc = $self->hacc;

   unless ($data = $self->data and $data->[ 0 ]) {
      $html  = $hacc->b   ( { class => q(pad)              }, $NBSP );
      $html .= $hacc->span( { class => q(navigationFiller) }, $NBSP );

      return $html;
   }

   my $selected = $data->[ 0 ]->{selected} || -1;

   for my $index (0 .. $#{ $data }) {
      if ($self->spacer and $index > 0) {
         $text  = $hacc->b   ( { class => q(pad) }, $NBSP );
         $text .= $hacc->span( { class => q(navigationFiller) },
                               $self->spacer );
         $html .= $hacc->li  ( $text );
      }

      $text    = $self->select && $index == $selected
               ? $self->_top_filler( $hacc )
               : $hacc->b( { class => q(pad) }, $NBSP );
      $content = $data->[ $index ]->{items}->[ 0 ]->{content} || q();
      $text   .= $self->inflate( $content );

      my $count = 0; my $dlist = q();

      for my $item (@{ $data->[ $index ]->{items} }) {
         $dlist .= $count < 1
                 ? $hacc->dt()
                 : $hacc->dd( $self->inflate( $item->{content} ) );
         $count++;
      }

      $dlist .= $self->_bottom_filler( $hacc ) if ($count > 1);

      $html  .= $hacc->li( $text.$hacc->dl( $dlist ) );
   }

   return $hacc->ul( { id => $args->{id} }, $html );
}

# Private methods

sub _bottom_filler {
   my ($self, $hacc) = @_; my ($fill, $html);

   $fill  = $hacc->b( { class => q(b4) } );
   $fill .= $hacc->b( { class => q(b3) } );
   $fill .= $hacc->b( { class => q(b2) } );
   $fill .= $hacc->b( { class => q(b1) } );
   $html  = $hacc->b( { class => q(bottom) }, $fill );

   return $hacc->dd( $html);
}

sub _top_filler {
   my ($self, $hacc) = @_; my ($fill, $html);

   $fill  = $hacc->b( { class => q(tl1) } );
   $fill .= $hacc->b( { class => q(tl2) } );
   $fill .= $hacc->b( { class => q(tl3) } );
   $fill .= $hacc->b( { class => q(tl4) } );
   $html  = $hacc->b( { class => q(left) }, $fill );
   $html .= $NBSP;
   $fill  = $hacc->b( { class => q(tr1) } );
   $fill .= $hacc->b( { class => q(tr2) } );
   $fill .= $hacc->b( { class => q(tr3) } );
   $fill .= $hacc->b( { class => q(tr4) } );
   $html .= $hacc->b( { class => q(right) }, $fill );

   return $hacc->b( { class => q(top) }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
