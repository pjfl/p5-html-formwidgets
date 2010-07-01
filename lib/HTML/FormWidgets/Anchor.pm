# @(#)$Id$

package HTML::FormWidgets::Anchor;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config fhelp href imgclass onclick) );

sub init {
   my ($self, $args) = @_;

   $self->class          ( q(anchor_fade) );
   $self->config         ( undef          );
   $self->container_class( q(label_text)  );
   $self->fhelp          ( q()            );
   $self->href           ( undef          );
   $self->imgclass       ( undef          );
   $self->onclick        ( undef          );
   $self->text           ( q(link)        );
   $self->tiptype        ( q(normal)      );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $html = $self->imgclass
            ? $self->text
            ? $hacc->img ( { alt   => $self->fhelp,
                             class => $self->imgclass,
                             src   => $self->text } )
            : $hacc->span( { class => $self->imgclass } )
            : $self->text;

   $self->href or return $html;

   delete $args->{name};
   $args->{class  } = $self->class;
   $args->{href   } = $self->href;
   $args->{onclick} = $self->onclick if ($self->onclick);

   $html = $hacc->a( $args, $html );

   if ($self->id and $self->config) {
      $html .= $self->_js_config( 'anchors', $self->id, $self->config );
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

