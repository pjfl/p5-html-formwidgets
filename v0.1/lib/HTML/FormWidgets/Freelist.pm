package HTML::FormWidgets::Freelist;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($htag, $html, $rNo, $text, $text1, $tip, $val);

   $htag            = $me->elem;
   $ref->{name    } = q(new).$me->name;
   $ref->{size    } = $me->width || 20;
   $html            = $htag->div( { class => q(container) },
                                  $htag->textfield( $ref ) );
   $html           .= $htag->div( { class => q(separator) }, q(&nbsp;) );

   $ref             = {};
   $ref->{class   } = $ref->{name} = q(button);
   $ref->{onclick } = 'return freeListObj.AddItem(\''.$me->name.'\')';
   $ref->{src     } = $me->assets.'AddItem.png';
   $ref->{value   } = q(add).(ucfirst $me->name);
   $text            = $htag->image_button( $ref );
   $tip             = 'Enter a new item into the adjacent text field ';
   $tip            .= 'and then click this button to add it to the list';
   $ref             = { class => q(help tips), title => $tip };
   $text1           = $htag->span( $ref, $text ).$htag->br();

   $ref             = {};
   $ref->{class   } = $ref->{name} = q(button);
   $ref->{onclick } = 'return freeListObj.RemoveItem(\''.$me->name.'\')';
   $ref->{src     } = $me->assets.'RemoveItem.png';
   $ref->{value   } = q(remove).(ucfirst $me->name);
   $text            = $htag->image_button( $ref );
   $tip             = 'Select one or more items from the adjacent list ';
   $tip            .= 'and then click this button to remove them';
   $ref             = { class => q(help tips), title => $tip };
   $text1          .= $htag->span( $ref, $text );
   $html           .= $htag->div( { class => q(container) }, $text1 );

   $ref             = {};
   $ref->{labels  } = $me->labels if ($me->labels);
   $ref->{multiple} = q(true);
   $ref->{name    } = q(cur).$me->name;
   $ref->{size    } = $me->height;
   $ref->{values  } = $me->values;
   $html           .= $htag->scrolling_list( $ref );
   $rNo             = 0;

   for $val (@{ $ref->{values} }) {
      $ref          = {};
      $ref->{id   } = $me->name.$rNo++;
      $ref->{name } = $me->name;
      $ref->{value} = $val;
      $html        .= $htag->hidden( $ref );
   }

   $ref             = {};
   $ref->{name    } = q(nRows).$me->name;
   $ref->{value   } = $rNo;
   $html           .= $htag->hidden( $ref );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
