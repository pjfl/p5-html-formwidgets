# @(#)$Id$

package HTML::FormWidgets::GroupMembership;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent q(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip all assets atitle ctitle current
                              fhelp height remove_tip labels) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->all            ( [] );
   $self->assets         ( q() );
   $self->atitle         ( q(All) );
   $self->container_class( q(groupmember_container) );
   $self->ctitle         ( q(Current) );
   $self->current        ( [] );
   $self->fhelp          ( q() );
   $self->height         ( 10 );
   $self->hint_title     ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->labels         ( undef );
   $self->sep            ( $self->space ) unless ($args->{prompt});

   $text = $self->loc( q(groupMembershipAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(groupMembershipRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args)  = @_;
   my $hacc           = $self->hacc;
   my $fargs          = { class => q(instructions) };
   my $html;

   $self->palign and $fargs->{style} .= 'text-align: '.$self->palign.'; ';
   $self->pwidth and $fargs->{style} .= 'width: '.$self->pwidth.q(;);
   $self->fhelp  and $html            = $hacc->span( $fargs, $self->fhelp );

   my $text  = $hacc->span( { class => q(title) }, $self->atitle );
   my $class = ($args->{class} || q()).q( ifield group);

   $args->{class   }  = $class.q( groupmembers);
   $args->{id      }  = $self->id;
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{size    }  = $self->height;
   $args->{name    }  = q(_).$self->name;
   $args->{values  }  = $self->all;

   $text     .= $hacc->scrolling_list( $args );
   $html     .= $hacc->span( { class => q(groupmember_ifields) }, $text );
   $text      = $hacc->span( { class => q(add_item_icon) }, q( ) );

   my $ref    = {
      class   => q(button icon tips add),
      id      => $self->id.q(_add),
      title   => $self->add_tip };
   my $text1  = $hacc->span( $ref, $text );

   $text      = $hacc->span( { class => q(remove_item_icon) }, q( ) );
   $ref       = {
      class   => q(button icon tips remove),
      id      => $self->id.q(_remove),
      title   => $self->remove_tip };
   $text1    .= $hacc->span( $ref, $text );
   $html     .= $hacc->span( { class => q(groupmember_buttons) }, $text1 );
   $text      = $hacc->span( { class => q(title) }, $self->ctitle );

   $args->{class } = $class;
   $args->{id    } = $self->id.q(_current);
   $args->{name  } = q(_).$self->name.q(_current);
   $args->{values} = $self->current;

   $text     .= $hacc->scrolling_list( $args );
   $html     .= $hacc->span( { class => q(groupmember_ifields) }, $text );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
