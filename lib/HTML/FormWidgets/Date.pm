# @(#)$Ident: Date.pm 2013-05-16 14:22 pjf ;

package HTML::FormWidgets::Date;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.20.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config width) );

my $SPC = q( );
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->config  ( { align       => q("bR"),
                      ifFormat    => q("%d/%m/%Y"),
                      singleClick => q(true) } );
   $self->readonly( 1  );
   $self->width   ( 10 );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $self->add_optional_js( qw(calendar.js calendar-setup.js) );
   $self->add_literal_js ( 'calendars', $self->id, $self->config );

   $args->{class} .= ($args->{class} ? q( ) : q()).q(ifield calendars);
   $args->{size }  = $self->width;

   my $hacc = $self->hacc;
   my $html = $hacc->textfield( $args );
   my $icon = $hacc->span( { class => q(calendar_icon) }, $SPC );
   my $hint = $self->hint_title.$TTS.$self->loc( q(dateWidgetTip) );
   my $text = $hacc->span( { class => q(icon_button tips),
                             id    => $self->id.q(_trigger),
                             title => $hint }, $icon );
   my $clear_hint = $self->hint_title.$TTS.$self->loc( q(clearFieldTip) );


   $icon    = $hacc->span( { class => q(clear_field_icon) }, $SPC );
   $text   .= $hacc->span( { class => q(icon_button tips),
                             id    => $self->id.q(_clear),
                             title => $clear_hint }, $icon );
   $html   .= $text;

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

