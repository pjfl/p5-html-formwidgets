# @(#)$Id$

package HTML::FormWidgets::Freelist;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip height remove_tip values width) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->container_class( q(freelist_container) );
   $self->height         ( 5 );
   $self->hint_title     ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->values         ( [] );
   $self->width          ( 20 );

   $text = $self->loc( q(freelistAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(freelistRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $args              = {};
   $args->{class   } .= q( ifield freelist);
   $args->{id      }  = $self->id;
   $args->{name    }  = q(_).$self->name;
   $args->{size    }  = $self->width;

   my $html   = $hacc->textfield( $args );

   $args              = {};
   $args->{class   }  = q( ifield freelist);
   $args->{id      }  = $self->id.q(_list);
   $args->{multiple}  = q(true);
   $args->{name    }  = q(_).$self->name.q(_list);
   $args->{size    }  = $self->height;
   $args->{values  }  = $self->values;

   $html    .= $hacc->scrolling_list( $args );

   for my $val (@{ $self->{values} }) {
      $html .= $hacc->hidden( { name => $self->name, value => $val } );
   }

   $html     = $hacc->span( { class => q(freelist_ifields) }, $html );

   my $text  = $hacc->span( { class => q(add_item_icon) }, q( ) );

   $args     = {
      class  => q(icon_button tips add),
      id     => $self->id.q(_add),
      title  => $self->add_tip };

   my $text1 = $hacc->span( $args, $text );

   $text     = $hacc->span( { class => q(remove_item_icon) }, q( ) );
   $args     = {
      class  => q(icon_button tips remove),
      id     => $self->id.q(_remove),
      title  => $self->remove_tip };
   $text1   .= $hacc->span( $args, $text );
   $html    .= $hacc->span( { class => q(freelist_buttons) }, $text1 );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
