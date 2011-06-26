# @(#)$Id$

package HTML::FormWidgets::Slider;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/g );
use parent qw(HTML::FormWidgets);

my $NUL = q();

__PACKAGE__->mk_accessors( qw(config display hide) );

sub init {
   my ($self, $args) = @_;

   $self->config ( { knob_class => q(".knob"),
                     mode       => q("horizontal"),
                     offset     => 0,
                     range      => q(false),
                     snap       => q(true),
                     steps      => 100,
                     wheel      => q(true), } );
   $self->default( 50 );
   $self->display( 1  );
   $self->hide   ( [] );

   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $hacc = $self->hacc;
   my $id   = $args->{name}.q(_slider);
   my $size = int ((log $self->config->{steps}) / (log 10));
   my $html = $NUL;
   my $text;

   if ($self->display) {
      $html .= $hacc->textfield( { class    => q(ifield),
                                   name     => $args->{name},
                                   readonly => q(readonly),
                                   size     => $size,
                                   value    => $args->{default} } );
   }
   else {
      push @{ $self->hide }, {
         content => $hacc->input( { name  => $args->{name},
                                    type  => q(hidden),
                                    value => $args->{default} } ) };
   }

   $text  = $hacc->span( { class => q(knob) } );
   $text  = $hacc->span( { class => q(slider), id => $id }, $text );

   for (0 .. 10) {
      my $style = q(left: ).(-1 + $_ * 20).q(px;);

      $text .= $hacc->span( { class => q(tick), style => $style } );
   }

   $html .= $hacc->span( { class => q(slider_group) }, $text );

   $self->config->{default_v} = $args->{default};
   $self->config->{name     } = '"'.$args->{name}.'"';

   $self->_js_config( 'sliders', $id, $self->config );

   return $html;
}

1;

__END__

# Local Variables:
# mode: perl
# tab-width: 3
# End:
