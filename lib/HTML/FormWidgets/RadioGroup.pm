package HTML::FormWidgets::RadioGroup;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref)   = @_;

   $ref->{columns}  = $self->columns  if ($self->columns);
   $ref->{labels}   = $self->labels   if ($self->labels);
   $ref->{onchange} = $self->onchange if ($self->onchange);
   $ref->{values}   = $self->values;
   return $self->elem->radio_group( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
