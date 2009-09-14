package HTML::FormWidgets::Slider;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/g );

my $NUL = q();

__PACKAGE__->mk_accessors( qw(display element hide js_obj mode offset range
                              snap steps wheel) );

sub _init {
   my ($self, $args) = @_;

   $self->display( 1                            );
   $self->element( q(behaviour.sliderElement)   );
   $self->hide   ( []                           );
   $self->js_obj ( q(behaviour.submit.setField) );
   $self->mode   ( q(horizontal)                );
   $self->offset ( 0                            );
   $self->range  ( q(false)                     );
   $self->snap   ( 1                            );
   $self->steps  ( 100                          );
   $self->wheel  ( 1                            );

   return;
}

sub _render {
   my ($self, $args) = @_;

   my $hacc = $self->hacc;
   my $elem = $self->element;
   my $id   = $self->name.q(_slider);
   my $size = int ((log $self->steps) / (log 10));
   my $html = $NUL;
   my $text;

   $args->{default} ||= q(50);

   if ($self->display) {
      $html .= $hacc->textfield( { name     => $self->name,
                                   readonly => q(readonly),
                                   size     => $size,
                                   value    => $args->{default} } );
   }
   else {
      push @{ $self->hide }, {
         content => $hacc->input( { name  => $self->name,
                                    type  => q(hidden),
                                    value => $args->{default} } ) };
   }

   $text  = $hacc->div( { class => q(knob) } );
   $html .= $hacc->div( { class => q(slider), id => $id }, $text );

   for (0 .. 10) {
      my $style = q(left: ).(45 + $_ * 20).q(px;);

      $html .= $hacc->div( { class => q(tick), style => $style } );
   }

   $text  = "\n";
   $text .= $elem.' = $( "'.$id.'" );'."\n";
   $text .= 'new Slider( '.$elem.', '.$elem.'.getElement( ".knob" ), {'."\n";
   $text .= '   mode     : "'.$self->mode.'",'."\n";
   $text .= '   offset   : '.$self->offset.','."\n";
   $text .= '   onChange : function( value ) {'."\n";
   $text .= '      '.$self->js_obj.'( "'.$self->name.'", value ); },'."\n";
   $text .= '   range    : '.$self->range.','."\n";
   $text .= '   snap     : '.($self->snap  ? 'true' : 'false' ).','."\n";
   $text .= '   steps    : '.$self->steps.','."\n";
   $text .= '   wheel    : '.($self->wheel ? 'true' : 'false' )."\n";
   $text .= '} ).set( '.$args->{default}.' );'."\n";
   $html .= $hacc->script( { type => q(text/javascript) }, $text );

   return $html;
}

1;

__END__

# Local Variables:
# mode: perl
# tab-width: 3
# End:
