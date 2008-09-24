package HTML::FormWidgets::Date;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use Readonly;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $TTS => q( ~ );

__PACKAGE__->mk_accessors( qw(assets form format width) );

sub init {
   my ($self, $args) = @_;

   $self->assets( q() );
   $self->form(   {} );
   $self->format( q(dd/MM/yyyy) );
   $self->width(  10 );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($hacc, $html, $text);

   $hacc              = $self->hacc;
   $args->{readonly}  = 1;
   $args->{size    }  = $self->width;
   $text              = $hacc->textfield( $args );
   $html              = $hacc->div( { class => q(container) }, $text );
   $html             .= $hacc->div( { class => q(separator) }, q(&nbsp;) );
   $text              = 'function getAnchorPosition(anchorname) {';
   $text             .= 'var coordinates = new Object();';
   $text             .= 'coordinates.x = 0; coordinates.y = 0;';
   $text             .= 'return coordinates; }';
   $text             .= 'var '.$self->name."_cal = new CalendarPopup('";
   $text             .= $self->name."_calendar'); ";
   $text             .= $self->name."_cal.offsetX = 0; ";
   $text             .= $self->name."_cal.offsetY = 0; ";
   $html             .= $hacc->script( { type => q(text/javascript) }, $text );
   $args              = { alt => q(Calendar), class => q(icon) };
   $args->{src     }  = $self->assets.'calendar.png';
   $text              = $hacc->img( $args );
   $args              = {};
   $args->{class   }  = q(tips);
   $args->{href    }  = q();
   $args->{id      }  = $self->name.'_anchor';
   $args->{onclick }  = $self->name.'_cal.select( document.forms[0].';
   $args->{onclick } .= $self->name.", '".$self->name."_anchor', '";
   $args->{onclick } .= $self->format."' ); ";
   $args->{onclick } .= 'return false;';
   $args->{title   }  = $self->hint_title.$TTS.$self->msg( q(dateWidgetTip) );
   $text              = $hacc->a( $args, $text );
   $text             .= $hacc->div( { class => q(calendar hidden),
                                      id    => $self->name.'_calendar' } );
   $html             .= $hacc->div( { class => q(container) }, $text );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

