# @(#)$Id$

package HTML::FormWidgets::Date;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(clear_hint config hint readonly width) );

my $SPC = q( );
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $hint = $self->loc( q(Hint) );

   $self->clear_hint( $hint.$TTS.$self->loc( q(clearFieldTip) ) );
   $self->config    ( { align       => q("bR"),
                        ifFormat    => q("%d/%m/%Y"),
                        singleClick => q(true) } );
   $self->hint      ( $hint.$TTS.$self->loc( q(dateWidgetTip) ) );
   $self->readonly  ( 1 );
   $self->width     ( 10 );

   push @{ $self->optional_js }, qw(calendar.js calendar-setup.js);
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $args->{class   } .= q( ifield calendars);
   $args->{readonly}  = q(readonly) if ($self->readonly);
   $args->{size    }  = $self->width;

   my $hacc = $self->hacc;
   my $html = $hacc->textfield( $args );
   my $icon = $hacc->span( { class => q(calendar_icon) }, $SPC );
   my $text = $hacc->span( { class => q(button icon tips),
                             id    => $self->id.q(_trigger),
                             title => $self->hint }, $icon );

   $icon    = $hacc->span( { class => q(clear_field_icon) }, $SPC );
   $text   .= $hacc->span( { class => q(button icon tips),
                             id    => $self->id.q(_clear),
                             title => $self->clear_hint }, $icon );
   $html   .= $hacc->span( { class => q(icon_buttons) }, $text );
   $html   .= $self->_js_config( 'calendars', $self->id, $self->config );

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

