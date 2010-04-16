# @(#)$Id$

package HTML::FormWidgets::Date;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(assets clear_hint format hint js_obj
                              readonly width) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $hint = $self->loc( q(Hint) );

   $self->assets    ( q() );
   $self->clear_hint( $hint.$TTS.$self->loc( q(clearFieldTip) ) );
   $self->format    ( q(%d/%m/%Y) );
   $self->hint      ( $hint.$TTS.$self->loc( q(dateWidgetTip) ) );
   $self->js_obj    ( q(behaviour.submit.clearField) );
   $self->readonly  ( 1 );
   $self->width     ( 10 );

   push @{ $self->optional_js }, qw(calendar.js calendar-setup.js);
   return;
}

sub render_field {
   my ($self, $args) = @_; my ($hacc, $html, $text);

   $hacc              = $self->hacc;
   $args->{class   } .= q( ifield);
   $args->{readonly}  = q(readonly) if ($self->readonly);
   $args->{size    }  = $self->width;
   $html              = $hacc->textfield( $args );
   $args              = { class   => q(calendar_icon) };
   $text              = $hacc->span( $args, q( ) );
   $args              = { class   => q(icon tips),
                          id      => $self->id.q(_trigger),
                          title   => $self->hint };
   $html             .= $hacc->span( $args, $text );
   $args              = { class   => q(clear_field_icon) };
   $text              = $hacc->span( $args, q( ) );
   $args              = { class   => q(icon tips),
                          id      => $self->id.q(_clear),
                          onclick => $self->js_obj."( '".$self->id."' )",
                          title   => $self->clear_hint };
   $html             .= $hacc->span( $args, $text );
   $text              = "\n";
   $text             .= 'Calendar.setup( {'."\n";
   $text             .= '   inputField : "'.$self->id.'", '."\n";
   $text             .= '   ifFormat   : "'.$self->format.'", '."\n";
   $text             .= '   button     : "'.$self->id.'_trigger", '."\n";
   $text             .= '   align      : "bR", '."\n";
   $text             .= '   singleClick: true } );';
   $html             .= $hacc->script( { type => q(text/javascript) }, $text );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

