package HTML::FormWidgets::Collection;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_;

   return join q(), map { $_->{value} } @{ $me->data };
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
