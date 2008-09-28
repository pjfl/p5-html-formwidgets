package HTML::FormWidgets::Date;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(assets format readonly width) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->assets(   q() );
   $self->format(   q(%d/%m/%Y) );
   $self->readonly( 1 );
   $self->width(    10 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($hacc, $html, $text);

   $hacc              = $self->hacc;
   $args->{readonly}  = 1 if ($self->readonly);
   $args->{size    }  = $self->width;
   $text              = $hacc->textfield( $args );
   $html              = $hacc->div( { class => q(container) }, $text );
   $html             .= $hacc->div( { class => q(separator) }, q(&nbsp;) );
   $args              = { alt => q(Calendar), class => q(icon) };
   $args->{id      }  = $self->id.'_trigger';
   $args->{src     }  = $self->assets.'calendar.png';
   $text              = $hacc->img( $args );
   $args              = {};
   $args->{class   }  = q(tips);
   $args->{href    }  = q();
   $args->{title   }  = $self->hint_title.$TTS.$self->msg( q(dateWidgetTip) );
   $text              = $hacc->a( $args, $text );
   $html             .= $hacc->div( { class => q(container) }, $text );
   $text              = 'Calendar.setup( {';
   $text             .= 'inputField : "'.$self->id.'", ';
   $text             .= 'ifFormat   : "'.$self->format.'", ';
   $text             .= 'button     : "'.$self->id.'_trigger", ';
   $text             .= 'align      : "bR", ';
   $text             .= 'singleClick: true } );';
   $html             .= $hacc->script( { type => q(text/javascript) }, $text );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

