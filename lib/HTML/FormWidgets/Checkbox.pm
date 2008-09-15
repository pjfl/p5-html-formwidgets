package HTML::FormWidgets::Checkbox;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref)  = @_;

   $ref->{checked} = q(checked) if ($self->checked);
   $ref->{value  } = $self->value;
   my $htag        = $self->elem;
   my $html        = $htag->checkbox( $ref );
   my $label       = $self->labels && $self->labels->{ $self->value }
                   ? $self->labels->{ $self->value }
                   : undef;
   return $html.$htag->span( { class => q(note) }, $label )
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
