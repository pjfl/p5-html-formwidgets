# @(#)$Id$

package HTML::FormWidgets::Rule;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.12.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(alt config href imgclass) );

sub init {
   my ($self, $args) = @_;

   $self->alt      ( undef );
   $self->config   ( {}    );
   $self->container( 0     );
   $self->href     ( undef );
   $self->imgclass ( undef );
   return;
}

sub render_field {
   my ($self, $args) = @_; my ($cells, $html); my $hacc = $self->hacc;

   if ($self->imgclass) {
      $html  = $hacc->hr  ( { class => $self->class } );
      $cells = $hacc->td  ( { class => q(minimal rule_section) }, $html );
      $html  = $self->text
             ? $hacc->img ( { alt   => $self->alt,
                              class => $self->imgclass,
                              src   => $self->text } )
             : $hacc->span( { class => $self->imgclass } );
   }
   else { $html = $self->text }

   $self->href and $html = $self->inflate( { class     => q(togglers),
                                             config    => $self->config,
                                             container => 0,
                                             href      => $self->href,
                                             id        => $self->id,
                                             text      => $html,
                                             type      => q(anchor) } );

   if ($html and $self->tip) {
      $html = $hacc->span( { class => q(tips), title => $self->tip }, $html );
      $self->tip( undef );
   }

   $html and $cells .= $hacc->td( { class => q(minimal) }, $html );
   $cells .= $hacc->td( { class => q(most rule_section) },
                        $hacc->hr( { class => $self->class } ) );

   return $hacc->table( { class => q(rule) }, $hacc->tr( $cells ) );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

