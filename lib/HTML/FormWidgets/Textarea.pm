package HTML::FormWidgets::Textarea;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref)  = @_;

   $ref->{cols} = $self->width || 60;
   $ref->{rows} = $self->height;

   return $self->elem->textarea( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
