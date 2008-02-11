package HTML::FormWidgets::Freelist;

# @(#)$Id: Freelist.pm 196 2007-10-15 01:07:07Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 196 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($html, $rNo, $text, $text1, $tip, $val);

   $ref->{name}     = 'new'.$me->name;
   $ref->{size}     = $me->width;
   $html            = $me->elem->div({ class => 'container' },
                                     $me->elem->textfield($ref));
   $html           .= $me->elem->div({ class => 'separator' }, '&nbsp;');

   $ref             = {};
   $ref->{class}    = $ref->{name} = 'button';
   $ref->{onclick}  = 'return freeListObj.AddItem(\''.$me->name.'\')';
   $ref->{src}      = $me->assets.'AddItem.png';
   $ref->{value}    = 'add'.(ucfirst $me->name);
   $text            = $me->elem->image_button($ref);
   $tip             = 'Enter a new item into the adjacent text field ';
   $tip            .= 'and then click this button to add it to the list';
   $ref             = { class => 'help tips', title => $tip };
   $text1           = $me->elem->span($ref, $text).$me->elem->br();

   $ref             = {};
   $ref->{class}    = $ref->{name} = 'button';
   $ref->{onclick}  = 'return freeListObj.RemoveItem(\''.$me->name.'\')';
   $ref->{src}      = $me->assets.'RemoveItem.png';
   $ref->{value}    = 'remove'.(ucfirst $me->name);
   $text            = $me->elem->image_button($ref);
   $tip             = 'Select one or more items from the adjacent list ';
   $tip            .= 'and then click this button to remove them';
   $ref             = { class => 'help tips', title => $tip };
   $text1          .= $me->elem->span($ref, $text);
   $html           .= $me->elem->div({ class => 'container' }, $text1);

   $ref             = {};
   $ref->{labels}   = $me->labels if ($me->labels);
   $ref->{multiple} = 'true';
   $ref->{name}     = 'cur'.$me->name;
   $ref->{size}     = $me->height;
   $ref->{values}   = $me->values;
   $html           .= $me->elem->scrolling_list($ref);
   $rNo             = 0;

   for $val (@{$ref->{values}}) {
      $ref          = {};
      $ref->{id}    = $me->name.$rNo++;
      $ref->{name}  = $me->name;
      $ref->{value} = $val;
      $html        .= $me->elem->hidden($ref);
   }

   $ref             = {};
   $ref->{name}     = 'nRows'.$me->name;
   $ref->{value}    = $rNo;
   $html           .= $me->elem->hidden($ref);
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
