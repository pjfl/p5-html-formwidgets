# @(#)$Id$

package HTML::FormWidgets::Note;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(width) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0 );
   $self->sep(       q() );
   $self->width(     undef );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $text;

   $args           = { class => q(container note) };
   $args->{style} .= 'text-align: '.$self->align.q(;) if ($self->align);
   $args->{style} .= ' width: '.$self->width.q(;)     if ($self->width);

   ($text = $self->text || $self->loc( $self->name )) =~ s{ \A \n }{}msx;

   return $self->hacc->div( $args, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
