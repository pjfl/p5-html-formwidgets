package HTML::FormWidgets::Rule;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(alt href imgclass) );

sub init {
   my ($self, $args) = @_;

   $self->alt(       undef );
   $self->container( 0 );
   $self->href(      undef );
   $self->imgclass(  undef );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($cells, $html); my $hacc = $self->hacc;

   if ($self->imgclass) {
      $html  = $hacc->hr(  { class => $self->class } );
      $cells = $hacc->td(  { class => q(minimal) }, $html );
      $html  = $hacc->img( { alt   => $self->alt,
                             class => $self->imgclass,
                             src   => $self->text } );
   }
   else { $html = $self->text }

   $html = $hacc->a( { href => $self->href }, $html ) if ($self->href);

   if ($self->tip) {
      $html = $hacc->span( { class => q(tips), title => $self->tip }, $html );
      $self->tip( undef );
   }

   $cells .= $hacc->td( { class => q(minimal) }, $html ) if ($html);
   $cells .= $hacc->td( $hacc->hr( { class => $self->class } ) );

   return $hacc->table( { class => q(rule) }, $hacc->tr( $cells ) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

