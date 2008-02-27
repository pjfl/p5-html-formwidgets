package HTML::FormWidgets::Date;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use Readonly;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $TTS => q( ~ );

sub _render {
   my ($me, $ref) = @_; my ($format, $htag, $html, $text);

   $htag            = $me->elem;
   $ref->{size   }  = $me->width || 10;
   $format          = $me->format || q(dd/MM/yyyy);
   $text            = $htag->textfield( $ref );
   $html            = $htag->div( { class => q(container) }, $text );
   $html           .= $htag->div( { class => q(separator) }, q(&nbsp;) );
   $text            = 'var cal_'.$me->name.' = new CalendarPopup(\'';
   $text           .= $me->name.'_calendar\');';
   $text            = $htag->script( $text );
   $ref             = {};
   $ref->{class  }  = q(icon);
   $ref->{src    }  = $me->assets.'calendar.png';
   $text           .= $htag->img( $ref );
   $ref             = {};
   $ref->{class  }  = q(tips);
   $ref->{href   }  = q();
   $ref->{id     }  = 'anchor_'.$me->name;
   $ref->{onclick}  = 'cal_'.$me->name.'.select( document.forms[0].'.$me->name;
   $ref->{onclick} .= ', '.'\'anchor_'.$me->name.'\', \''.$format.'\' ); ';
   $ref->{onclick} .= 'return false;';
   $ref->{title  }  = $me->hint_title.$TTS.$me->msg( q(dateWidgetTip) );
   $text            = $htag->a( $ref, $text );
   $html           .= $htag->div( { class => q(container) }, $text );
   $html           .= $htag->div( { class => q(calendar hidden),
                                    id    => $me->name.'_calendar' } );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

