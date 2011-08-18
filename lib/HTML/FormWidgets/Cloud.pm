# @(#)$Id$

package HTML::FormWidgets::Cloud;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(data height) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0  );
   $self->data     ( {} );
   $self->height   ( 18 );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   for my $item (@{ $self->data }) {
      my $ref        = $item->{value};
      my $class_pref = $ref->{class_pref};
      my $id_pref    = $ref->{id_pref   };
      my $href       = $ref->{href      } || 'javascript:Expand_Collapse()';
      my $style      = $ref->{style     };
      my $id         = $id_pref.q(_).$ref->{name};
      my $attrs      = { class   => $class_pref.q(_header fade live_grid),
                         href    => $href,
                         id      => $id };

      if ($item->{size}) {
         # Assumes 1em = 10px
         my $mult        = 1 + int (10 * $item->{size} / $self->height);
         my $height      = $mult * $self->height;
         my $line_height = (int 0.5 + (100 * $height / $item->{size})) / 1000;

         $style .= 'font-size: '.$item->{size}.'em; ';
         $style .= "line-height: ${line_height}em; ";
         $style .= "height: ${height}px; ";
      }

      $item->{colour} and $style .= 'color: '.$item->{colour}.'; ';
      $style and $attrs->{style}  = $style;

      my $text    = $ref->{labels}->{ $ref->{name} };
         $text   .= '('.$ref->{total}.')' if exists $ref->{total};
      my $anchor  = $hacc->a( $attrs, "\n".$text );
      my $class   = $class_pref.q(_header).q( ).$class_pref.q(Subject);

      $html      .= $hacc->div( { class => $class }, "\n".$anchor )."\n";

      if (not $ref->{href}) {
         $style   = 'display: none; width: '.$ref->{width}.'px;';
         $html   .= $hacc->div( { class => $class_pref.q(Panel),
                                  id    => $id.q(Disp),
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
