# @(#)$Id$

package HTML::FormWidgets::Password;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.14.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(subtype width) );

sub init {
   my ($self, $args) = @_;

   $self->subtype( undef );
   $self->width(   20 );
   return;
}


sub render_field {
   my ($self, $args) = @_; my $html;

   $args->{class} .= q( ifield);
   $args->{size }  = $self->width;
   $html           = $self->hacc->password_field( $args );

   return $html unless ($self->subtype && $self->subtype eq q(verify));

   $html .= $self->hacc->span( { class => q(prompt) },
                               $self->loc( q(vPasswordPrompt) ) );
   $args->{name} =~ s{ 1 }{2}mx; $args->{id} =~ s{ 1 }{2}mx;
   $html .= $self->hacc->password_field( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
