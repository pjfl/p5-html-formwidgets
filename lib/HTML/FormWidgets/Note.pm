package HTML::FormWidgets::Note;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(width) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0 );
   $self->sep(       q() );
   $self->width(     undef );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $ref) = @_; my $text;

   $ref           = { class => q(note) };
   $ref->{style} .= 'text-align: '.$self->align.q(;) if ($self->align);
   $ref->{style} .= ' width: '.$self->width.q(;)     if ($self->width);

   ($text = $self->msg( $self->name ) || $self->text) =~ s{ \A \n }{}msx;

   return $self->elem->div( $ref, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
