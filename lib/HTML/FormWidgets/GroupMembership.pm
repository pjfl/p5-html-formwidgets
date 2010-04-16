# @(#)$Id$

package HTML::FormWidgets::GroupMembership;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip all assets atitle ctitle current
                              fhelp height js_obj remove_tip labels) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->all        ( [] );
   $self->assets     ( q() );
   $self->atitle     ( q(All) );
   $self->ctitle     ( q(Current) );
   $self->current    ( [] );
   $self->fhelp      ( q() );
   $self->height     ( 10 );
   $self->hint_title ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->js_obj     ( q(behaviour.groupMember) );
   $self->labels     ( undef );
   $self->sep        ( $self->space ) unless ($args->{prompt});

   $text = $self->loc( q(groupMembershipAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(groupMembershipRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args) = @_;
   my ($fargs, $hacc, $html, $ref, $text, $text1, $tip, $val);

   $hacc              = $self->hacc;
   $fargs             = { class => q(instructions) };
   $fargs->{style}   .= 'text-align: '.$self->palign.'; '   if ($self->palign);
   $fargs->{style}   .= 'width: '.$self->pwidth.q(;)        if ($self->pwidth);
   $html              = $hacc->span( $fargs, $self->fhelp ) if ($self->fhelp);
   $text              = $hacc->span( { class => q(title) }, $self->atitle );
   $text             .= $hacc->br();
   $args->{class   } .= q( group ifield);
   $args->{id      }  = $self->id     if ($self->id);
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{size    }  = $self->height;
   $args->{name    }  = $self->name.q(_all);
   $args->{values  }  = $self->all;
   $text             .= $hacc->scrolling_list( $args );
   $html             .= $hacc->span( { class => q(container) }, $text );
   $html             .= $hacc->span( { class => q(separator) }, $self->space );

   $text1             = $hacc->br().$hacc->br().$hacc->br();
   $text              = $hacc->span( { class => q(add_item_icon) }, q( ) );
   $ref               = {
      class   => q(button icon tips),
      name    => $self->name.q(_remove_item),
      onclick => 'return '.$self->js_obj.".addItem('".$self->name."')",
      title   => $self->add_tip };
   $text1            .= $hacc->span( $ref, $text ).$hacc->br().$hacc->br();

   $text              = $hacc->span( { class => q(remove_item_icon) }, q( ) );
   $ref               = {
      class   => q(button icon tips),
      onclick => 'return '.$self->js_obj.".removeItem('".$self->name."')",
      title   => $self->remove_tip };
   $text1            .= $hacc->span( $ref, $text );
   $html             .= $hacc->span( { class => q(container) }, $text1 );

   delete $args->{id};
   $html             .= $hacc->span(  { class => q(separator) }, $self->space);
   $text              = $hacc->span( { class => q(title) }, $self->ctitle );
   $text             .= $hacc->br();
   $args->{name  }    = $self->name.q(_current);
   $args->{values}    = $self->current;
   $text             .= $hacc->scrolling_list( $args );
   $html             .= $hacc->span( { class => q(container) }, $text );

   $args              = {};
   $args->{name  }    = $self->name.q(_n_added);
   $args->{value }    = 0;
   $html             .= $hacc->hidden( $args );
   $args->{name  }    = $self->name.q(_n_deleted);
   $html             .= $hacc->hidden( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
