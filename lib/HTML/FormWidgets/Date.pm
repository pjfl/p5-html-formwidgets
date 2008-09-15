package HTML::FormWidgets::Date;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use Readonly;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $TTS => q( ~ );

sub _render {
   my ($self, $ref) = @_; my ($format, $htag, $html, $text);

   $htag            = $self->elem;
   $ref->{size   }  = $self->width || 10;
   $format          = $self->format || q(dd/MM/yyyy);
   $text            = $htag->textfield( $ref );
   $html            = $htag->div( { class => q(container) }, $text );
   $html           .= $htag->div( { class => q(separator) }, q(&nbsp;) );
   $text            = 'function getAnchorPosition(anchorname) {';
   $text           .= 'var coordinates = new Object();';
	$text           .= 'coordinates.x = 0; coordinates.y = 0;';
	$text           .= 'return coordinates; }';
   $text           .= 'var '.$self->name."_cal = new CalendarPopup('";
   $text           .= $self->name."_calendar'); ";
   $text           .= $self->name."_cal.offsetX = 0; ";
   $text           .= $self->name."_cal.offsetY = 0; ";
   $html           .= $htag->script( { type => q(text/javascript) }, $text );
   $ref             = { alt => q(Calendar), class => q(icon) };
   $ref->{src    }  = $self->assets.'calendar.png';
   $text            = $htag->img( $ref );
   $ref             = {};
   $ref->{class  }  = q(tips);
   $ref->{href   }  = q();
   $ref->{id     }  = $self->name.'_anchor';
   $ref->{onclick}  = $self->name.'_cal.select( document.forms[0].';
   $ref->{onclick} .= $self->name.", '".$self->name."_anchor', '";
   $ref->{onclick} .= $format."' ); ";
   $ref->{onclick} .= 'return false;';
   $ref->{title  }  = $self->hint_title.$TTS.$self->msg( q(dateWidgetTip) );
   $text            = $htag->a( $ref, $text );
   $text           .= $htag->div( { class => q(calendar hidden),
                                    id    => $self->name.'_calendar' } );
   $html           .= $htag->div( { class => q(container) }, $text );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

