package HTML::FormWidgets::Password;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(subtype width) );

sub init {
   my ($self, $args) = @_;

   $self->subtype( undef );
   $self->width(   20 );

   $self->NEXT::init( $args );
   return;
}


sub _render {
   my ($self, $args) = @_; my $html;

   $args->{size} = $self->width;
   $html         = $self->elem->password_field( $args );

   return $html unless ($self->subtype && $self->subtype eq q(verify));

   $html .= $self->msg( q(vPasswordPrompt) );
   $args->{name} =~ s{ 1 }{2}mx; $args->{id} =~ s{ 1 }{2}mx;
   $html .= $self->elem->password_field( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
