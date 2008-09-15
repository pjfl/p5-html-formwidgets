package HTML::FormWidgets::Freelist;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my ($htag, $html, $rno, $text, $text1, $tip, $val);

   $htag            = $self->elem;
   $ref->{name    } = $self->name.q(_new);
   $ref->{size    } = $self->width || 20;
   $html            = $htag->div( { class => q(container) },
                                  $htag->textfield( $ref ) );
   $html           .= $htag->div( { class => q(separator) }, $self->space );

   $ref             = {};
   $ref->{class   } = $ref->{name} = q(button);
   $ref->{onclick } = "return freeListObj.addItem('".$self->name."')";
   $ref->{src     } = $self->assets.'AddItem.png';
   $ref->{value   } = q(add).(ucfirst $self->name);
   $text            = $htag->image_button( $ref );
   $tip             = 'Enter a new item into the adjacent text field ';
   $tip            .= 'and then click this button to add it to the list';
   $ref             = { class => q(help tips), title => $tip };
   $text1           = $htag->span( $ref, $text ).$htag->br().$htag->br();

   $ref             = {};
   $ref->{class   } = $ref->{name} = q(button);
   $ref->{onclick } = "return freeListObj.removeItem('".$self->name."')";
   $ref->{src     } = $self->assets.'RemoveItem.png';
   $ref->{value   } = q(remove).(ucfirst $self->name);
   $text            = $htag->image_button( $ref );
   $tip             = 'Select one or more items from the adjacent list ';
   $tip            .= 'and then click this button to remove them';
   $ref             = { class => q(help tips), title => $tip };
   $text1          .= $htag->span( $ref, $text );
   $html           .= $htag->div( { class => q(container) }, $text1 );

   $html           .= $htag->div( { class => q(separator) }, $self->space );
   $ref             = {};
   $ref->{labels  } = $self->labels if ($self->labels);
   $ref->{multiple} = q(true);
   $ref->{name    } = $self->name.q(_current);
   $ref->{size    } = $self->height;
   $ref->{values  } = $self->values;
   $html           .= $htag->scrolling_list( $ref );
   $rno             = 0;

   for $val (@{ $ref->{values} }) {
      $ref          = {};
      $ref->{id   } = $self->name.$rno++;
      $ref->{name } = $self->name;
      $ref->{value} = $val;
      $html        .= $htag->hidden( $ref );
   }

   $ref             = {};
   $ref->{name    } = $self->name.q(_n_rows);
   $ref->{value   } = $rno;
   $html           .= $htag->hidden( $ref );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
