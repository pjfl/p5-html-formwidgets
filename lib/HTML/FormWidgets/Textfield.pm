package HTML::FormWidgets::Textfield;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_;

   $ref->{size} = $me->width || 40;

   return $me->elem->textfield( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
