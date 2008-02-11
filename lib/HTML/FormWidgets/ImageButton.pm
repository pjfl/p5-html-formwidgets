package HTML::FormWidgets::ImageButton;

# @(#)$Id: ImageButton.pm 301 2008-01-28 16:55:20Z pjf $

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 301 $ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my $text;

   $ref            = {};
   $ref->{class  } = q(button);
   $ref->{name}    = q(_verb);
   $ref->{onclick} = 'submit()';
   $ref->{src    } = $me->assets.$me->name.'.png';
   $ref->{value  } = ucfirst $me->name;
   $text           = $me->elem->image_button( $ref );
   $ref            = { class => q(help tips), title => $me->tip };
   return $me->elem->span( $ref, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

