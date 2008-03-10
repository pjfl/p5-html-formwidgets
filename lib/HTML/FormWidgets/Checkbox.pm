package HTML::FormWidgets::Checkbox;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref)  = @_;

   $ref->{checked} = $me->checked if ($me->checked);
   $ref->{value  } = $me->value;
   my $htag        = $me->elem;
   my $html        = $htag->checkbox( $ref );
   my $label       = $me->labels && $me->labels->{ $me->value }
                   ? $me->labels->{ $me->value }
                   : undef;
   return $html.$htag->span( { class => q(note) }, $label )
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
