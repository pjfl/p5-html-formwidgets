package HTML::FormWidgets::GroupMembership;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($htag, $html, $ref1, $text, $text1, $tip, $val);

   $htag             = $me->elem;
   $text             = $htag->span( { class => q(title) }, $me->atitle );
   $text            .= $htag->br();
   $ref->{class   } .= q( group);
   $ref->{id      }  = $me->id     if ($me->id);
   $ref->{labels  }  = $me->labels if ($me->labels);
   $ref->{multiple}  = q(true);
   $ref->{size    }  = $me->height;
   $ref->{name    }  = $me->name   if ($me->name);
   $ref->{name    } .= q(_all);
   $ref->{values  }  = $me->all;
   $text            .= $htag->scrolling_list( $ref );
   $html             = $htag->div( { class => q(container) }, $text );
   $html            .= $htag->div( { class => q(separator) }, $me->space );

   $text1            = $htag->br().$htag->br().$htag->br();
   $ref1             = {};
   $ref1->{class  }  = $ref1->{name} = q(button);
   $ref1->{onclick}  = 'return groupMemberObj.addItem(\''.$me->name.'\')';
   $ref1->{src    }  = $me->assets.'AddItem.png';
   $ref1->{value  }  = q(add).(ucfirst $me->name);
   $text             = $htag->image_button( $ref1 );
   $tip              = 'Select one or more entries from the list on the left ';
   $tip             .= 'and then click this button to add them to the list ';
   $tip             .= 'on the right';
   $ref1             = { class => q(help tips), title => $tip };
   $text1           .= $htag->span( $ref1, $text ).$htag->br().$htag->br();

   $ref1             = {};
   $ref1->{class  }  = $ref1->{name} = q(button);
   $ref1->{onclick}  = 'return groupMemberObj.removeItem(\''.$me->name.'\')';
   $ref1->{src    }  = $me->assets.'RemoveItem.png';
   $ref1->{value  }  = q(remove).(ucfirst $me->name);
   $text             = $htag->image_button( $ref1 );
   $tip              = 'Select one or more entries from the list on the ';
   $tip             .= 'right and then click this button to remove them';
   $ref1             = { class => q(help tips), title => $tip };
   $text1           .= $htag->span( $ref1, $text );
   $html            .= $htag->div( { class => q(container) }, $text1 );

   delete $ref->{id};
   $html            .= $htag->div(  { class => q(separator) }, $me->space );
   $text             = $htag->span( { class => q(title)     }, $me->ctitle );
   $text            .= $htag->br();
   $ref->{name    }  = $me->name if ($me->name);
   $ref->{name    } .= q(_current);
   $ref->{values  }  = $me->current;
   $text            .= $htag->scrolling_list( $ref );
   $html            .= $htag->div( { class => q(container) }, $text );

   $ref              = {};
   $ref->{name    }  = $me->name.q(_n_added);
   $ref->{value   }  = 0;
   $html            .= $htag->hidden( $ref );
   $ref->{name    }  = $me->name.q(_n_deleted);
   $html            .= $htag->hidden( $ref );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
