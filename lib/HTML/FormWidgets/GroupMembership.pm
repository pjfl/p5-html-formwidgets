package HTML::FormWidgets::GroupMembership;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(add_tip all assets atitle ctitle current
                              fhelp height js_obj remove_tip labels) );

sub init {
   my ($self, $args) = @_; my $text;

   $text  = 'Select one or more entries from the list on the ';
   $text .= 'left and then click this button to add them to the ';
   $text .= 'list on the right';
   $self->add_tip(    $self->msg( q(groupMembershipAddTip) ) || $text );
   $self->all(        [] );
   $self->assets(     q() );
   $self->atitle(     q(All) );
   $self->ctitle(     q(Current) );
   $self->current(    [] );
   $self->fhelp(      q() );
   $self->height(     10 );
   $self->js_obj(     q(groupMemberObj) );
   $text  = 'Select one or more entries from the list on the ';
   $text .= 'right and then click this button to remove them';
   $self->remove_tip( $self->msg( q(groupMembershipRemoveTip) ) || $text );
   $self->labels(     undef );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_;
   my ($fargs, $hacc, $html, $ref, $text, $text1, $tip, $val);

   $hacc              = $self->hacc;
   $fargs             = { class => q(instructions) };
   $fargs->{style}   .= 'text-align: '.$self->palign.'; ' if ($self->palign);
   $fargs->{style}   .= 'width: '.$self->pwidth.q(;)      if ($self->pwidth);
   $html              = $self->sep ? q() : $hacc->div( $fargs, $self->fhelp );
   $text              = $hacc->span( { class => q(title) }, $self->atitle );
   $text             .= $hacc->br();
   $args->{class   } .= q( group);
   $args->{id      }  = $self->id     if ($self->id);
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{size    }  = $self->height;
   $args->{name    }  = $self->name.q(_all);
   $args->{values  }  = $self->all;
   $text             .= $hacc->scrolling_list( $args );
   $html             .= $hacc->div( { class => q(container) }, $text );
   $html             .= $hacc->div( { class => q(separator) }, $self->space );

   $text1             = $hacc->br().$hacc->br().$hacc->br();
   $ref               = {};
   $ref->{class  }    = $ref->{name} = q(button);
   $ref->{onclick}    = 'return '.$self->js_obj.".addItem('".$self->name."')";
   $ref->{src    }    = $self->assets.'add_item.png';
   $ref->{value  }    = q(add).(ucfirst $self->name);
   $text              = $hacc->image_button( $ref );
   $ref               = { class => q(help tips), title => $self->add_tip };
   $text1            .= $hacc->span( $ref, $text ).$hacc->br().$hacc->br();

   $ref               = {};
   $ref->{class  }    = $ref->{name} = q(button);
   $ref->{onclick}    = 'return '.$self->js_obj.".removeItem('";
   $ref->{onclick}   .= $self->name."')";
   $ref->{src    }    = $self->assets.'remove_item.png';
   $ref->{value  }    = q(remove).(ucfirst $self->name);
   $text              = $hacc->image_button( $ref );
   $ref               = { class => q(help tips), title => $self->remove_tip };
   $text1            .= $hacc->span( $ref, $text );
   $html             .= $hacc->div( { class => q(container) }, $text1 );

   delete $args->{id};
   $html             .= $hacc->div(  { class => q(separator) }, $self->space );
   $text              = $hacc->span( { class => q(title) }, $self->ctitle );
   $text             .= $hacc->br();
   $args->{name  }    = $self->name.q(_current);
   $args->{values}    = $self->current;
   $text             .= $hacc->scrolling_list( $args );
   $html             .= $hacc->div( { class => q(container) }, $text );

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
