package HTML::FormWidgets::Textarea;

# @(#)$Id: Textarea.pm 196 2007-10-15 01:07:07Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 196 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)  = @_;

   $ref->{cols} = $me->width; $ref->{rows} = $me->height;
   return $me->elem->textarea( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
