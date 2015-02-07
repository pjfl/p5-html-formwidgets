package HTML::FormWidgets::Button;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( button_name config src value ) );

my $TTS = ' ~ ';

# Private methods
my $_image_button = sub {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $src   = 'http:' eq (substr $self->src, 0, 5)
             ? $self->src : $self->options->{assets}.$self->src;
   my $image = $hacc->img( { alt   => ucfirst $self->name,
                             class => 'button',
                             src   => $src } );

   $args->{class} = $self->class || 'image_button submit';
   $args->{name } = $self->button_name;
   $args->{value} = $self->value // $self->name;

   return $hacc->button( $args, $image );
};

my $_markup_button = sub {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   my $class = $self->src->{class} || 'button_replacement';

   for my $char (split m{}m, $self->src->{content} || 'Button') {
      $html .= $hacc->span( { class => $class }, $char );
   }

   $args->{class} = $self->class || 'markup_button submit';

   return $hacc->span( $args, $html );
};

my $_reset_button = sub {
   my ($self, $args) = @_;

   $args->{class} = $self->class || 'reset_button';
   $args->{type } = 'reset';
   $args->{value} = $self->value // $self->name;

   return $self->hacc->button( $args, ucfirst $self->name );
};

my $_submit_button = sub {
   my ($self, $args) = @_;

   $args->{class} = $self->class || 'submit_button submit';
   $args->{name } = $self->button_name;
   $args->{type } = 'submit';
   $args->{value} = $self->value // $self->name;

   return $self->hacc->button( $args, ucfirst $self->name );
};

# Public methods
sub init {
   my ($self, $args) = @_;

   $self->button_name( '_method' );
   $self->config     ( undef     );
   $self->container  ( 0         );
   $self->src        ( q()       );
   $self->tiptype    ( 'normal'  );
   $self->value      ( undef     );
   return;
}

sub render_field {
   my $self = shift; my $args = {}; my $src = $self->src;

   $self->id and $args->{id} = $self->id and $self->config
      and $self->add_literal_js( 'anchors', $self->id, $self->config );

   return $src && ref $src eq 'HASH'  ? $self->$_markup_button( $args )
        : $src &&     $src eq 'reset' ? $self->$_reset_button ( $args )
        : $src                        ? $self->$_image_button ( $args )
                                      : $self->$_submit_button( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

