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
   my ($self, $ref) = @_; my $text;

   $ref->{size} = $self->width;
   $text        = $self->elem->password_field( $ref );

   return $text unless ($self->subtype && $self->subtype eq q(verify));

   $text .= $self->msg( q(vPasswordPrompt) );
   $ref->{name} =~ s{ 1 }{2}mx; $ref->{id} =~ s{ 1 }{2}mx;
   $text .= $self->elem->password_field( $ref );
   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
