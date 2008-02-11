package HTML::FormWidgets::Password;

# @(#)$Id: Password.pm 196 2007-10-15 01:07:07Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 196 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my $text;

   $ref->{size} = $me->width; $text = $me->elem->password_field( $ref );

   return $text unless ($me->subtype && $me->subtype eq 'verify');

   $text .= $me->messages->{vPasswordPrompt}->{text};
   $ref->{name} =~ s/1/2/; $ref->{id} =~ s/1/2/;
   $text .= $me->elem->password_field( $ref );
   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
