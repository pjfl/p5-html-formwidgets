package HTML::FormWidgets::Freelist;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.5.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(add_tip assets height js_obj labels
                              remove_tip values width) );

my $TTS = q( ~ );

sub _init {
   my ($self, $args) = @_; my $text;

   $self->assets( q() );
   $self->height( 5 );
   $self->js_obj( q(behaviour.freeList) );
   $self->labels( undef );
   $self->values( [] );
   $self->width(  20 );

   unless ($self->hint_title) {
      $self->hint_title( $self->loc( q(Hint ) ) );
   }

   $text  = 'Enter a new item into the adjacent text field ';
   $text .= 'and then click this button to add it to the list';
   $text  = $self->loc( q(freelistAddTip) ) || $text;
   $self->add_tip(    $self->hint_title.$TTS.$text );
   $text  = 'Select one or more items from the adjacent list ';
   $text .= 'and then click this button to remove them';
   $text  = $self->loc( q(freelistRemoveTip) ) || $text;
   $self->remove_tip( $self->hint_title.$TTS.$text );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($hacc, $html, $rno, $text, $text1, $tip, $val);

   $hacc              = $self->hacc;
   $args->{name    }  = $self->name.q(_new);
   $args->{size    }  = $self->width;
   $html              = $hacc->div( { class => q(container) },
                                    $hacc->textfield( $args ) );
   $html             .= $hacc->div( { class => q(separator) }, $self->space );

   $args              = {};
   $args->{class   }  = $args->{name} = q(button);
   $args->{onclick }  = 'return '.$self->js_obj.".addItem('".$self->name."')";
   $args->{src     }  = $self->assets.'add_item.png';
   $args->{value   }  = q(add).(ucfirst $self->name);
   $text              = $hacc->image_button( $args );
   $args              = { class => q(help tips), title => $self->add_tip };
   $text1             = $hacc->span( $args, $text ).$hacc->br().$hacc->br();

   $args              = {};
   $args->{class   }  = $args->{name} = q(button);
   $args->{onclick }  = 'return '.$self->js_obj;
   $args->{onclick } .= ".removeItem('".$self->name."')";
   $args->{src     }  = $self->assets.'remove_item.png';
   $args->{value   }  = q(remove).(ucfirst $self->name);
   $text              = $hacc->image_button( $args );
   $args              = { class => q(help tips), title => $self->remove_tip };
   $text1            .= $hacc->span( $args, $text );
   $html             .= $hacc->div( { class => q(container) }, $text1 );

   $html             .= $hacc->div( { class => q(separator) }, $self->space );
   $args              = {};
   $args->{labels  }  = $self->labels if ($self->labels);
   $args->{multiple}  = q(true);
   $args->{name    }  = $self->name.q(_current);
   $args->{size    }  = $self->height;
   $args->{values  }  = $self->values;
   $html             .= $hacc->scrolling_list( $args );
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
