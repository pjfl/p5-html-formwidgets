# @(#)$Id$

package HTML::FormWidgets::Freelist;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip assets height js_obj labels
                              remove_tip values width) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->assets     ( q() );
   $self->container  ( 0 );
   $self->height     ( 5 );
   $self->hint_title ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->js_obj     ( q(behaviour.freeList) );
   $self->labels     ( undef );
   $self->values     ( [] );
   $self->width      (  20 );

   $text = $self->loc( q(freelistAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(freelistRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args) = @_; my ($hacc, $html, $rno, $text, $text1, $tip, $val);

   $hacc              = $self->hacc;
   $args->{class   } .= q( ifield freelist);
   $args->{name    }  = $self->name.q(_new);
   $args->{size    }  = $self->width;
   $html              = $hacc->textfield( $args );
   $args              = {};
   $args->{class   }  = q( ifield freelist);
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{name    }  = $self->name.q(_current);
   $args->{size    }  = $self->height;
   $args->{values  }  = $self->values;
   $text1             = $hacc->scrolling_list( $args );
   $args              = { class => q(container freelist_scrolling) };
   $html             .= $hacc->span( $args, $text1 );
   $args              = { class => q(container freelist_container) };
   $html              = $hacc->span( $args, $html );
   $html             .= $hacc->span( { class => q(separator) }, $self->space );

   $text              = $hacc->span( { class => q(add_item_icon) }, q( ) );
   $args              = {
      class   => q(button icon tips),
      onclick => 'return '.$self->js_obj.".addItem('".$self->name."')",
      title   => $self->add_tip };
   $text1             = $hacc->span( $args, $text ).$hacc->br().$hacc->br();

   $text              = $hacc->span( { class => q(remove_item_icon) }, q( ) );
   $args              = {
      class   => q(button icon tips),
      onclick => 'return '.$self->js_obj.".removeItem('".$self->name."')",
      title   => $self->remove_tip };
   $text1            .= $hacc->span( $args, $text );
   $html             .= $hacc->span( { class => q(container) }, $text1 );

   $rno               = 0;

   for $val (@{ $args->{values} }) {
      $args           = {};
      $args->{id   }  = $self->name.$rno++;
      $args->{name }  = $self->name;
      $args->{value}  = $val;
      $html          .= $hacc->hidden( $args );
   }

   $args              = {};
   $args->{name    }  = $self->name.q(_n_rows);
   $args->{value   }  = $rno;
   $html             .= $hacc->hidden( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
