package HTML::FormWidgets::Chooser;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my $onclick;

   $onclick        = 'return submitObj.Chooser(';
   $onclick       .= 'document.'.$me->form->{name}.q(.).$me->field;
   $onclick       .= '.value, document.'.$me->form->{name}.', ';
   $onclick       .= q(\').$me->key.'\', \''.$me->form->{action}.'\', ';
   $onclick       .= q(\').$me->form->{name}.'\', \''.$me->title.'\', ';
   $onclick       .= q(\').$me->class.'\', \''.$me->field.'\', ';

   if ($me->where->{field}) {
      $onclick    .= q(\').$me->where->{field}.'\', ';
      $onclick    .= q(\').$me->where->{value}.'\', ';
   }
   else { $onclick .= '\'\', \'\', ' }

   $onclick       .= '\'width='.($me->width || 250).', screenX=100, ';
   $onclick       .= 'height='.($me->height || 150).', screenY=50, ';
   $onclick       .= 'dependent=yes, titlebar=no, scrollbars=yes\')';
   $ref->{onclick} = $onclick;
   $ref->{value}   = $me->button;

   return $me->elem->submit( $ref );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
