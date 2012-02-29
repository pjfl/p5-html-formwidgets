# @(#)$Id$

package HTML::FormWidgets::Flag;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.9.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use Lingua::Flags;

sub init {
   my $self = shift;

   $self->container( 0 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $flag = as_html_img( $self->text ) || $self->text;

   $self->is_xml or $flag =~ s{ \s* / > }{>}msx;

   return $flag;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
