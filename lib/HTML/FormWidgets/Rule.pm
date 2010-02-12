# @(#)$Id$

package HTML::FormWidgets::Rule;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(alt href imgclass onclick) );

sub init {
   my ($self, $args) = @_;

   $self->alt(       undef );
   $self->container( 0 );
   $self->href(      undef );
   $self->imgclass(  undef );
   $self->onclick(   undef );
   return;
}

sub render_field {
   my ($self, $args) = @_; my ($cells, $html); my $hacc = $self->hacc;

   if ($self->imgclass) {
      $html  = $hacc->hr(  { class => $self->class } );
      $cells = $hacc->td(  { class => q(minimal) }, $html );
      $html  = $hacc->img( { alt   => $self->alt,
                             class => $self->imgclass,
                             src   => $self->text } );
   }
   else { $html = $self->text }

   if ($self->href) {
      my $ref = { href => $self->href };
      $ref->{onclick} = $self->onclick if ($self->onclick);
      $html = $hacc->a( $ref, $html );
   }

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

