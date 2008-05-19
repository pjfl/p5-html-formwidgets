package HTML::FormWidgets::Cloud;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_;
   my ($anchor, $attrs, $class, $class_pref, $hacc, $href, $html);
   my ($id_pref, $item, $onclick, $style, $text);

   $hacc = $me->elem;

   for $item (@{ $me->data }) {
      $ref        = $item->{value};
      $class_pref = $ref->{class_pref};
      $id_pref    = $ref->{id_pref   };
      $href       = $ref->{href      };
      $onclick    = $ref->{onclick   };
      $style      = $ref->{style     };
      $attrs      = { class => $class_pref.q(HeaderFade),
                      id    => $id_pref.$ref->{name} };

      $style     .= 'font-size: '.$item->{size}.'em; ' if ($item->{size});
      $style     .= 'color: #'.$item->{colour}.'; '    if ($item->{colour});

      if (!$href && !$onclick ) {
         $href     = 'javascript:windowObj.Expand_Collapse()';
         $onclick  = "gridObj.Table('$id_pref', '".$ref->{name};
         $onclick .= "', 'a~b', $ref->{table_len}, 1)";
      }

      $attrs->{href   } = $href    if ($href);
      $attrs->{onclick} = $onclick if ($onclick);
      $attrs->{style  } = $style   if ($style);

      $text       = $ref->{labels}->{ $ref->{name} };
      $text      .= '('.$ref->{total}.')' if exists $ref->{total};
      $anchor     = $hacc->a( $attrs, "\n".$text );

      $class      = $class_pref.q(Header).q( ).$class_pref.q(Subject);
      $html      .= $hacc->div( { class => $class }, "\n".$anchor )."\n";

      if (!$ref->{href} && !$ref->{onclick}) {
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
