package HTML::FormWidgets::Checkbox;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)  = @_;

   $ref->{checked} = $me->checked if ($me->checked);
   $ref->{label  } = $me->labels && $me->labels->{ $me->value }
                   ? $me->labels->{ $me->value }
                   : ' ';
   $ref->{value  } = $me->value;

   return $me->elem->checkbox( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
