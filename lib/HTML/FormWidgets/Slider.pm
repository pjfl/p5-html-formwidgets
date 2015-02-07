package HTML::FormWidgets::Slider;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw(config display) );

sub init {
   my ($self, $args) = @_;

   $self->config ( { knob_class => q(".knob"),
                     mode       => q("horizontal"),
                     offset     => 0,
                     range      => 'false',
                     snap       => 'true',
                     steps      => 100,
                     wheel      => 'true', } );
   $self->default( 50 );
   $self->display( 1  );

   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $hacc = $self->hacc;
   my $id   = $args->{name}.'_slider';
   my $size = int ((log $self->config->{steps}) / (log 10));
   my $html = q();
   my $text;

   if ($self->display) {
      $html .= $hacc->textfield( { class    => 'ifield numeric',
                                   name     => $args->{name},
                                   readonly => 'readonly',
                                   size     => $size,
                                   value    => $args->{default} } );
   }
   else { $self->add_hidden( $args->{name}, $args->{default} ) }

   $text  = $hacc->span( { class => 'knob' } );
   $text  = $hacc->span( { class => 'slider', id => $id }, $text );

   for (0 .. 10) {
      my $style = 'left: '.(-1 + $_ * 20).'px;';

      $text .= $hacc->span( { class => 'tick', style => $style } );
   }

   $html .= $hacc->span( { class => 'slider_group' }, $text );

   $self->config->{default_v} = $args->{default};
   $self->config->{name     } = '"'.$args->{name}.'"';

   $self->add_literal_js( 'sliders', $id, $self->config );

   return $html;
}

1;

__END__

# Local Variables:
# mode: perl
# tab-width: 3
# End:
