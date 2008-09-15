package HTML::FormWidgets::Rule;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my ($cells, $html); my $htag = $self->elem;

   $self->container( undef );

   if ($self->imgclass) {
      $html  = $htag->hr(  { class => $self->class } );
      $cells = $htag->td(  { class => q(minimal) }, $html );
      $html  = $htag->img( { alt   => $self->alt,
                             class => $self->imgclass,
                             src   => $self->text } );
   }
   else { $html = $self->text }

   $html = $htag->a( { href => $self->href }, $html ) if ($self->href);

   if ($self->tip) {
      $html = $htag->span( { class => q(tips), title => $self->tip }, $html );
      $self->tip( undef );
   }

   $cells .= $htag->td( { class => q(minimal) }, $html ) if ($html);
   $cells .= $htag->td( $htag->hr( { class => $self->class } ) );
   return $htag->table( { class => q(rule) }, $htag->tr( $cells ) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

