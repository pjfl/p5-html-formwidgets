# @(#)$Id$

package HTML::FormWidgets::Button;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(assets button_name config src) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->assets     ( q()        );
   $self->button_name( q(_method) );
   $self->config     ( {}         );
   $self->container  ( 0          );
   $self->src        ( q()        );
   $self->tiptype    ( q(normal)  );
   return;
}

sub render_field {
   my $self = shift;
   my $hacc = $self->hacc;
   my $args = { id => $self->id };
   my $html = $self->src && ref $self->src eq q(HASH)
            ? $self->_markup_button( $args )
            : $self->src
            ? $self->_image_button ( $args )
            : $self->_submit_button( $args );

   keys %{ $self->config } > 0
      and $self->_js_config( 'anchors', $self->id, $self->config );

   return $html;
}

sub _image_button {
   my ($self, $args) = @_;

   $args->{alt  } = ucfirst $self->name;
   $args->{class} = q(image_button ).$self->class;
   $args->{name } = $self->button_name;
   $args->{value} = ucfirst $self->name;
   $args->{src  } = q(http:) eq (substr $self->src, 0, 5)
                  ? $self->src : $self->assets.$self->src;

   return $self->hacc->image_button( $args );
}

sub _markup_button {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   my $class = $self->src->{class} || q(button_replacement);

   for my $char (split m{}m, $self->src->{content} || 'Button') {
      $html .= $hacc->span( { class => $class }, $char );
   }

   $args->{class} = q(markup_button ).$self->class;

   return $hacc->div( $args, $html );
}

sub _submit_button {
   my ($self, $args) = @_;

   $args->{class} = q(submit_button ).$self->class;
   $args->{name } = $self->button_name;
   $args->{value} = ucfirst $self->name;

   return $self->hacc->submit( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

