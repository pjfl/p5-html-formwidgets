package HTML::FormWidgets::GroupMembership;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($htag, $html, $text);

   $htag             = $me->elem;
   $text             = $htag->span( { class => q(title) }, $me->atitle );
   $text            .= $htag->br();
   $ref->{class   } .= q( group);
   $ref->{id      }  = $me->id     if ($me->id);
   $ref->{labels  }  = $me->labels if ($me->labels);
   $ref->{multiple}  = q(true);
   $ref->{size    }  = $me->height;
   $ref->{name    }  = q(add);
   $ref->{name    } .= $me->name   if ($me->name);
   $ref->{values  }  = $me->all;
   $text            .= $htag->scrolling_list( $ref );
   $html             = $htag->div(  { class => q(container) }, $text );
   $html            .= $htag->div(  { class => q(separator) }, q(&nbsp;) );
   $text             = $htag->span( { class => q(title)     }, $me->ctitle );
   $text            .= $htag->br();
   delete $ref->{id};
   $ref->{name    }  = q(remove);
   $ref->{name    } .= $me->name   if ($me->name);
   $ref->{values  }  = $me->current;
   $text            .= $htag->scrolling_list( $ref );
   $html            .= $htag->div( { class => q(container) }, $text );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
