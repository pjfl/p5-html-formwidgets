package HTML::FormWidgets::RadioGroup;

# @(#)$Id: RadioGroup.pm 196 2007-10-15 01:07:07Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 196 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)   = @_;

   $ref->{columns}  = $me->columns  if ($me->columns);
   $ref->{labels}   = $me->labels   if ($me->labels);
   $ref->{onchange} = $me->onchange if ($me->onchange);
   $ref->{values}   = $me->values;
   return $me->elem->radio_group( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
