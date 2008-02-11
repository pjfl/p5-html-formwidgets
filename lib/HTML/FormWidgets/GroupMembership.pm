package HTML::FormWidgets::GroupMembership;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($html, $text);

   $text               = $me->elem->span({ class => 'title' },
                                         $me->atitle).$me->elem->br();
   $ref->{class}      .= ' group';
   $ref->{id}          = $me->id      if ($me->id);
   $ref->{labels}      = $me->labels  if ($me->labels);
   $ref->{multiple}    = 'true';
   $ref->{size}        = $me->height;
   $ref->{name}        = 'add';
   $ref->{name}       .= $me->name    if ($me->name);
   $ref->{values}      = $me->all;
   $text              .= $me->elem->scrolling_list($ref);
   $html               = $me->elem->div({ class => 'container' }, $text);
   $html              .= $me->elem->div({ class => 'separator' }, '&nbsp;');
   $text               = $me->elem->span({ class => 'title' },
                                         $me->ctitle).$me->elem->br();
   delete $ref->{id};
   $ref->{name}        = 'remove';
   $ref->{name}       .= $me->name    if ($me->name);
   $ref->{values}      = $me->current;
   $text              .= $me->elem->scrolling_list($ref);
   $html              .= $me->elem->div({ class => 'container' }, $text);

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
