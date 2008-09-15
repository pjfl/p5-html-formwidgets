package HTML::FormWidgets::Chooser;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my $onclick;

   $onclick  = 'return submitObj.chooser(';
   $onclick .= 'document.forms[0].'.$self->field.'.value, ';
   $onclick .= 'document.forms[0], ';
   $onclick .= '\''.$self->key.'\', ';
   $onclick .= '\''.$self->href.'\', ';
   $onclick .= '\'width='.$self->width.', screenX=0, ';
   $onclick .= 'height='.$self->height.', screenY=0, ';
   $onclick .= 'dependent=yes, titlebar=no, scrollbars=yes\')';
   $ref->{onclick} = $onclick;
   $ref->{value}   = $self->button;

   return $self->elem->submit( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
