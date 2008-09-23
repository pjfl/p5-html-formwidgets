package HTML::FormWidgets::GroupMembership;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(add_tip all assets atitle ctitle current
                              height js_obj remove_tip labels) );

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
   my ($self, $args) = @_; my ($htag, $html, $ref, $text, $text1, $tip, $val);

   $htag              = $self->elem;
   $text              = $htag->span( { class => q(title) }, $self->atitle );
   $text             .= $htag->br();
   $args->{class   } .= q( group);
   $args->{id      }  = $self->id     if ($self->id);
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{size    }  = $self->height;
   $args->{name    }  = $self->name.q(_all);
   $args->{values  }  = $self->all;
   $text             .= $htag->scrolling_list( $args );
   $html              = $htag->div( { class => q(container) }, $text );
   $html             .= $htag->div( { class => q(separator) }, $self->space );

   $text1             = $htag->br().$htag->br().$htag->br();
   $ref               = {};
   $ref->{class  }    = $ref->{name} = q(button);
   $ref->{onclick}    = 'return '.$self->js_obj.".addItem('".$self->name."')";
   $ref->{src    }    = $self->assets.'AddItem.png';
   $ref->{value  }    = q(add).(ucfirst $self->name);
   $text              = $htag->image_button( $ref );
   $ref               = { class => q(help tips), title => $self->add_tip };
   $text1            .= $htag->span( $ref, $text ).$htag->br().$htag->br();

   $ref               = {};
   $ref->{class  }    = $ref->{name} = q(button);
   $ref->{onclick}    = 'return '.$self->js_obj.".removeItem('";
   $ref->{onclick}   .= $self->name."')";
   $ref->{src    }    = $self->assets.'RemoveItem.png';
   $ref->{value  }    = q(remove).(ucfirst $self->name);
   $text              = $htag->image_button( $ref );
   $ref               = { class => q(help tips), title => $self->remove_tip };
   $text1            .= $htag->span( $ref, $text );
   $html             .= $htag->div( { class => q(container) }, $text1 );

   delete $args->{id};
   $html             .= $htag->div(  { class => q(separator) }, $self->space );
   $text              = $htag->span( { class => q(title) }, $self->ctitle );
   $text             .= $htag->br();
   $args->{name  }    = $self->name.q(_current);
   $args->{values}    = $self->current;
   $text             .= $htag->scrolling_list( $args );
   $html             .= $htag->div( { class => q(container) }, $text );

   $args              = {};
   $args->{name  }    = $self->name.q(_n_added);
   $args->{value }    = 0;
   $html             .= $htag->hidden( $args );
   $args->{name  }    = $self->name.q(_n_deleted);
   $html             .= $htag->hidden( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
