package HTML::FormWidgets::Textfield;

# @(#)$Id: Textfield.pm 228 2007-11-18 17:11:52Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 228 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; $ref->{size} = $me->width;

   return $me->elem->textfield( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
