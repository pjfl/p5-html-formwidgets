package HTML::FormWidgets::Note;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

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
   my ($self, $args) = @_; my $text;

   $args           = { class => q(note) };
   $args->{style} .= 'text-align: '.$self->align.q(;) if ($self->align);
   $args->{style} .= ' width: '.$self->width.q(;)     if ($self->width);

   ($text = $self->msg( $self->name ) || $self->text) =~ s{ \A \n }{}msx;

   return $self->hacc->div( $args, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
