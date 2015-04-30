package HTML::FormWidgets::GroupMembership;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( all current fhelp height labels ) );

my $SPACE = '&#160;' x 3;
my $TTS   = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->all            ( [] );
   $self->container_class( 'groupmember_container' );
   $self->current        ( [] );
   $self->fhelp          ( q() );
   $self->height         ( 10 );
   $self->labels         ( undef );
   $self->pclass         ( 'instructions' );
   $self->sep            ( $SPACE ) unless ($args->{prompt});
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   my $add_tip = $self->hint_title.$TTS.$self->loc( 'groupMembershipAddTip' );
   my $rm_tip  = $self->hint_title.$TTS.$self->loc( 'groupMembershipRemoveTip');
   my $fargs   = { class => $self->pclass };

   $self->pwidth and $fargs->{style} .= 'width: '.$self->pwidth.';';
   $self->fhelp  and $html            = $hacc->div( $fargs, $self->fhelp );

   my $text  = $hacc->span( { class => 'title' }, $self->loc( 'All' ) );
   my $class = ($args->{class} || q()).' ifield group';

   $args->{class   }  = "${class} groupmembers";
   $args->{id      }  = $self->id;
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = 'true';
   $args->{size    }  = $self->height;
   $args->{name    }  = '_'.$self->name;
   $args->{values  }  = $self->all;

   $text     .=  $hacc->scrolling_list( $args );
   $html     .=  $hacc->div ( { class => 'groupmember_ifields' }, $text );
   $text      =  $hacc->span( { class => 'add_item_icon' }, q( ) );

   my $ref    =  {
      class   => 'icon_button tips add',
      id      => $self->id.'_add',
      title   => $add_tip };
   my $text1  =  $hacc->span( $ref, $text );

   $text      =  $hacc->span( { class => 'remove_item_icon' }, q( ) );
   $ref       =  {
      class   => 'icon_button tips remove',
      id      => $self->id.'_remove',
      title   => $rm_tip };
   $text1    .=  $hacc->span( $ref, $text );
   $html     .=  $hacc->div ( { class => 'groupmember_buttons' }, $text1 );
   $text      =  $hacc->span( { class => 'title' }, $self->loc( 'Current' ) );

   $args->{class } = $class;
   $args->{id    } = $self->id.'_current';
   $args->{name  } = '_'.$self->name.'_current';
   $args->{values} = $self->current;

   $text     .= $hacc->scrolling_list( $args );
   $html     .= $hacc->div( { class => 'groupmember_ifields' }, $text );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
