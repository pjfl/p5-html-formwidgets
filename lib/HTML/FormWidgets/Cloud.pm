# @(#)$Id$

package HTML::FormWidgets::Cloud;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(data js_obj) );

sub init {
   my ($self, $args) = @_;

   $self->data(   {} );
   $self->js_obj( q(behaviour.table.liveGrid) );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   for my $item (@{ $self->data }) {
      my $ref        = $item->{value};
      my $class_pref = $ref->{class_pref};
      my $id_pref    = $ref->{id_pref   };
      my $href       = $ref->{href      } || 'javascript:Expand_Collapse()';
      my $onclick    = $self->js_obj."('$id_pref', '".$ref->{name};
         $onclick   .= "', 'a~b', ".$ref->{table_len}.', 1)';
         $onclick    = $ref->{onclick   } || $onclick;
      my $style      = $ref->{style     };
      my $attrs      = { class   => $class_pref.q(_header_fade),
                         href    => $href,
                         id      => $id_pref.$ref->{name},
                         onclick => $onclick };

      $item->{size  } and $style .= 'font-size: '.$item->{size}.'em; ';
      $item->{colour} and $style .= 'color: #'.$item->{colour}.'; ';
      $style and $attrs->{style  } = $style;

      my $text    = $ref->{labels}->{ $ref->{name} };
         $text   .= '('.$ref->{total}.')' if exists $ref->{total};
      my $anchor  = $hacc->a( $attrs, "\n".$text );
      my $class   = $class_pref.q(_header).q( ).$class_pref.q(Subject);

      $html      .= $hacc->div( { class => $class }, "\n".$anchor )."\n";

      if (not $ref->{href} and not $ref->{onclick}) {
         $style   = 'display: none; width: '.$ref->{width}.'px;';
         $html   .= $hacc->div( { class => $class_pref.q(Panel),
                                  id    => $id_pref.$ref->{name}.q(Disp),
                                  style => $style }, 'Loading...' );
      }
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
