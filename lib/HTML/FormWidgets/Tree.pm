# @(#)$Id$

package HTML::FormWidgets::Tree;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);

__PACKAGE__->mk_accessors( qw(class_prefix data node_count selected) );

my $NUL = q();
my $SPC = q( );
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->class_prefix   ( q(tree)      );
   $self->container_class( q(container) );
   $self->data           ( {}           );
   $self->node_count     ( 0            );
   $self->selected       ( undef        );
   return;
}

sub node_id {
   my $self = shift; return $self->name.q(_node_).$self->{node_count}++;
}

sub render_field {
   my $self = shift;
   my $hacc = $self->hacc;
   my @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   defined $root[ 1 ] and return $hacc->span
      ( { class => q(error) }, 'Your tree has more than one root' );

   my $html  = $self->_image_button( q(expand),   q(Expand All)   );
      $html .= $self->_image_button( q(collapse), q(Collapse All) );
   my $args  = { class => $self->class_prefix.q(_controls) };
      $html  = $hacc->span( $args, $html );
      $html .= "\n".$self->traverse( { data => $self->data, fill => $NUL } );

   return $html;
}

sub traverse {
   my ($self, $args) = @_;

   my @keys = sort  { lc $a cmp lc $b }
              grep  { not m{ \A _ }mx }
              keys %{ $args->{data}   };

   $keys[ 0 ] or return $NUL;

   my $hacc  = $self->hacc; my $prefix = $self->class_prefix; my $html;
   my $class = $prefix.($self->node_count > 0 ? q(_branch) : $SPC.$self->class);
   my $attrs = { class => $class };

   $self->node_count > 0 or $attrs->{id} = $self->id;

   for my $key_no (0 .. $#keys) {
      my $attrs = { class => $prefix.q(_link fade) };
      my $key   = $keys[ $key_no ];
      my $data  = $args->{data}->{ $key };
      my $last  = $key_no == $#keys;
      my $node  = $self->node_id;
      my $text  = $key;
      my $tip   = $NUL;
      my ($list, $url);

      if (ref $data eq q(HASH)) {
         $node = $data->{_node_id} || $node;
         $text = $data->{_text   } || $text;
         $tip  = $data->{_tip    } || $tip;
         $url  = $data->{_url    };
      }

      if ($url) {
         $url =~ m{ \A http: }mx or $url = $self->options->{base}.$url;
         $self->selected and $url .= q(?).$self->name.q(_node=).$node;
         $attrs->{href} = $url;
      }
      else { $attrs->{href} = '#top' }

      my $link = $hacc->a( $attrs, $text );

      $attrs = { class => q(tips), title => $self->hint_title.$TTS.$tip };
      $link  = $hacc->span( $attrs, $link );
      $attrs = { class => $prefix.($last ? q(_last) : $NUL).q(_fill) };

      my $fill = $args->{fill}.($self->node_count > 1
                                ? $hacc->span( $attrs, $SPC ) : $NUL);

      ref $data eq q(HASH)
         and $list = $self->traverse( { data => $data, fill => $fill } );

      my $class = $prefix.($list ? q(_node) : q(_leaf));
      my $ctrl  = ($fill
                   ? $hacc->span( { class => $class.q(_ctrl) }, $SPC ) : $NUL);
      my $icon  = $hacc->span( { class => $class.q(_icon) }, $SPC );
      my $item  = ($args->{fill} ? $args->{fill} : $NUL).$ctrl.$icon.$link;

      $last and $class .= q(_last); $list and $class .= q(_open);

      $item  = $hacc->dt( { class => $class, id => $node }, $item );
      $html .= $item.($list ? $hacc->dd( { class => $class }, $list ) : $NUL);
   }

   return $hacc->dl( $attrs, $html );
}

sub _image_button {
   my ($self, $dirn, $tip) = @_; my $hacc = $self->hacc;

   return $hacc->span( {
      class => q(action tips ).$dirn,
      id    => $self->id.q(_).$dirn.q(_button),
      title => $self->hint_title.$TTS.$self->loc( $tip ) }, $SPC );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
