package HTML::FormWidgets::Date;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( config width ) );

my $SPC = q( );
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->config  ( { align       => '"bR"',
                      ifFormat    => '"%d/%m/%Y"',
                      singleClick => 'true' } );
   $self->readonly( 1  );
   $self->width   ( 10 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $self->add_optional_js( 'calendar.js', 'calendar-setup.js' );
   $self->add_literal_js ( 'calendars', $self->id, $self->config );

   $args->{class} .= ($args->{class} ? $SPC : q()).'ifield calendars';
   $args->{size }  = $self->width;

   my $html = $hacc->textfield( $args );
   my $hint = $self->hint_title.$TTS.$self->loc( 'dateWidgetTip' );
   my $icon = $hacc->span( { class => 'calendar_icon' }, $SPC );
   my $text = $hacc->span( { class => 'icon_button tips',
                             id    => $self->id.'_trigger',
                             title => $hint }, $icon );

   $hint    = $self->hint_title.$TTS.$self->loc( 'clearFieldTip' );
   $icon    = $hacc->span( { class => 'clear_field_icon' }, $SPC );
   $text   .= $hacc->span( { class => 'icon_button tips',
                             id    => $self->id.'_clear',
                             title => $hint }, $icon );
   $html   .= $text;

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

