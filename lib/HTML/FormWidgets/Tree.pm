# @(#)$Id$

package HTML::FormWidgets::Tree;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);

__PACKAGE__->mk_accessors( qw(base data node_count prefix selected static) );

my $NUL = q();
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->base      ( $NUL    );
   $self->data      ( {}      );
   $self->node_count( 0       );
   $self->prefix    ( q(tree) );
   $self->selected  ( undef   );
   $self->static    ( $NUL    );
   return;
}

sub node_id {
   my $self = shift; return $self->name.q(_node_).$self->{node_count}++;
}

sub render_field {
   my $self = shift;
   my $hacc = $self->hacc;
   my @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   defined $root[1] and return $hacc->span
      ( { class => q(error) }, 'Your tree has more than one root' );

   $self->hint_title
      or $self->hint_title( $self->loc( q(handy_hint_title) ) );

   my $html  = $self->_image_button( $hacc, q(expand),   q(Expand All)   );
      $html .= $self->_image_button( $hacc, q(collapse), q(Collapse All) );
   my $args  = { class => q(tree_controls) };
      $html  = $hacc->span( $args, $html );
      $args  = { data => $self->data, parent => $NUL, prev_key => $NUL };

   return $html."\n".$self->scan_hash( $args );
}

sub scan_hash {
   my ($self, $args) = @_;

   my @keys = sort  { lc $a cmp lc $b }
              grep  { ! m{ \A _ }mx   }
              keys %{ $args->{data}   };

   $keys[ 0 ] or return $NUL;

   my $hacc = $self->hacc; my $prefix = $self->prefix; my $html;

   for my $key_no (0 .. $#keys) {
      my $key     = $keys[ $key_no ];
      my $node    = $self->node_id;
      my $new_key = $args->{prev_key}
                  ? $args->{prev_key}.$SUBSEP.$key : $key;
      my $data    = $args->{data}->{ $key };
      my $text    = $key;
      my $tip     = $NUL;
      my ($list, $url);

      if (ref $data eq q(HASH)) {
         $node = $data->{_node_id} || $node;
         $text = $data->{_text   } || $text;
         $tip  = $data->{_tip    } || $tip;
         $url  = $data->{_url    };
         $list = $self->scan_hash
            ( { data => $data, parent => $node, prev_key => $new_key } );
      }

      my $attrs = { title => $tip };

      if ($url) {
         $url =~ m{ \A http: }mx or $url = $self->base.$url;
         $self->selected and $url .= q(?).$self->name.q(_node=).$node;
         $attrs->{href} = $url;
      }
      else { $attrs->{href} = '#top' }

      my $class = $list ? $prefix.q(_node) : $prefix.q(_leaf);

      $key_no == $#keys and $class .= q(_last);
      $class .= $list ? q(_open) : $NUL;

      my $item = $hacc->dt( { class => $class }, $hacc->a( $attrs, $text ) );

      $html .= $item.($list ? $hacc->dd( { class => $class }, $list ) : $NUL);
   }

   my $attrs = { class => $args->{parent} ? $prefix.q(_branch) : $prefix };

   $args->{parent} or $attrs->{id} = $self->id;

   return $hacc->dl( $attrs, $html );
}

sub _image_button {
   my ($self, $hacc, $dirn, $tip) = @_;

   my $args = { class   => q(action tips),
                onclick => $self->name.q(_node_0.).$dirn.'All()',
                src     => $self->static.q(images/).$dirn.q(.png),
                tiptype => q(normal),
                title   => $self->hint_title.$TTS.$self->loc( $tip ) };

   return $hacc->img( $args );
}

sub __wrap_cdata {
   my $code = shift; return q(//<![CDATA[).$code.q(//]]>);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
