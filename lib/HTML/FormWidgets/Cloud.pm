# @(#)$Id$

package HTML::FormWidgets::Cloud;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.15.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(data height width) );

sub init {
   my ($self, $args) = @_;

   $self->class    ( q(cloud) );
   $self->container( 0  );
   $self->data     ( [] );
   $self->height   ( 18 );
   $self->width    ( undef );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my $html;

   for my $item (@{ $self->data }) {
      my $ref    = $item->{value} || {};
      my $id     = $ref->{id   }  || $item->{tag};
      my $style  = $ref->{style};
      my $attrs  = { class => $self->class.q(_header fade live_grid),
                     href  => $ref->{href } || 'javascript:Expand_Collapse()',
                     id    => $id };

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

      my $text   = $item->{tag}.'('.$item->{count}.')';
      my $anchor = $hacc->a( $attrs, "\n".$text );

      $attrs     = { class => $self->class.q(_header) };
      $html     .= $hacc->div( $attrs, "\n".$anchor )."\n";

      $ref->{href} and next;

      $style     = defined $self->width ? 'width: '.$self->width.'px;' : q();
      $html     .= $hacc->div( { class => $self->class.q(_panel),
                                 id    => $id.q(Disp),
                                 style => $style }, 'Loading...' );
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
