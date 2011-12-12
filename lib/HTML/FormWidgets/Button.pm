# @(#)$Id$

package HTML::FormWidgets::Button;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.8.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(button_name config src) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->button_name( q(_method) );
   $self->config     ( undef      );
   $self->container  ( 0          );
   $self->src        ( q()        );
   $self->tiptype    ( q(normal)  );
   return;
}

sub render_field {
   my $self = shift; my $hacc = $self->hacc; my $args = {};

   $self->id and $args->{id} = $self->id and $self->config
      and $self->add_literal_js( 'anchors', $self->id, $self->config );

   return $self->src && ref $self->src eq q(HASH)
        ? $self->_markup_button( $args )
        : $self->src
        ? $self->_image_button ( $args )
        : $self->_submit_button( $args );
}

sub _image_button {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $src   = q(http:) eq (substr $self->src, 0, 5)
             ? $self->src : $self->options->{assets}.$self->src;
   my $image = $hacc->img( { alt   => ucfirst $self->name,
                             class => q(button),
                             src   => $src } );

   $args->{class} = $self->class || q(image_button submit);
   $args->{name } = $self->button_name;
   $args->{value} = ucfirst $self->name;

   return $hacc->button( $args, $image );
}

sub _markup_button {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   my $class = $self->src->{class} || q(button_replacement);

   for my $char (split m{}m, $self->src->{content} || 'Button') {
      $html .= $hacc->span( { class => $class }, $char );
   }

   $args->{class} = $self->class || q(markup_button submit);

   return $hacc->div( $args, $html );
}

sub _submit_button {
   my ($self, $args) = @_;

   $args->{class} = $self->class || q(submit_button submit);
   $args->{name } = $self->button_name;
   $args->{value} = ucfirst $self->name;

   return $self->hacc->submit( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

