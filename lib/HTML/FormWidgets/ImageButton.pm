package HTML::FormWidgets::ImageButton;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my $text;

   $ref            = {};
   $ref->{class  } = q(button);
   $ref->{name   } = q(_verb);
   $ref->{onclick} = 'submit()';
   $ref->{src    } = $self->assets.$self->name.'.png';
   $ref->{value  } = ucfirst $self->name;
   $text           = $self->elem->image_button( $ref );
   $ref            = { class => q(help tips), title => $self->tip };
   $self->tip( undef );
   return $self->elem->span( $ref, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

