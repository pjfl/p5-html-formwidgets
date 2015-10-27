package HTML::FormWidgets::Tree;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

use English qw( -no_match_vars );

__PACKAGE__->mk_accessors( qw( class_prefix data node_count selected ) );

my $NUL = q();
my $SPC = q( );
my $TTS = q( ~ );

my $_image_button = sub {
   my ($self, $dirn, $tip) = @_; my $hacc = $self->hacc;

   return $hacc->span( {
      class => "action tips ${dirn}",
      id    => $self->id."_${dirn}_button",
      title => $self->hint_title.$TTS.$self->loc( $tip ) }, $SPC );
};

sub init {
   my ($self, $args) = @_;

   $self->class_prefix( 'tree' );
   $self->data        ( {}     );
   $self->node_count  ( 0      );
   $self->selected    ( undef  );
   return;
}

sub node_id {
   my $self = shift; return $self->name.'_node_'.$self->{node_count}++;
}

sub render_field {
   my $self = shift;
   my $hacc = $self->hacc;
   my @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   defined $root[ 1 ] and return $hacc->span
      ( { class => 'error' }, 'Your tree has more than one root' );

   my $html  = $self->$_image_button( 'expand',   'Expand All'   );
      $html .= $self->$_image_button( 'collapse', 'Collapse All' );
   my $args  = { class => $self->class_prefix.'_controls' };
      $html  = $hacc->span( $args, $html );
      $html .= "\n".$self->traverse( { data => $self->data, fill => $NUL } );

   return $html;
}

sub traverse {
   my ($self, $args) = @_; my @keys = ();

   if (exists $args->{data}->{_keys}) { @keys = @{ $args->{data}->{_keys} } }
   else {
      @keys = sort  { lc $a cmp lc $b }
              grep  { not m{ \A _ }mx }
              keys %{ $args->{data}   };
   }

   $keys[ 0 ] or return $NUL;

   my $hacc  = $self->hacc; my $prefix = $self->class_prefix; my $html;
   my $class = $prefix.($self->node_count > 0 ? '_branch' : $SPC.$self->class);
   my $attr  = { class => $class };

   $self->node_count > 0 or $attr->{id} = $self->id;

   for my $key_no (0 .. $#keys) {
      my $attr = { class => $prefix.'_link fade' };
      my $key  = $keys[ $key_no ];
      my $data = $args->{data}->{ $key };
      my $last = $key_no == $#keys;
      my $node = $self->node_id;
      my $text = $key;
      my $tip  = $NUL;
      my ($list, $url);

      if (ref $data eq 'HASH') {
         $node = $data->{_node_id} // $node;
         $text = $data->{_text   } // $text;
         $tip  = $data->{_tip    } // $tip;
         $url  = $data->{_url    };
         $attr->{class} = $data->{_link_class} // $attr->{class};
      }

      if ($url) {
         $url = $self->uri_for( $url );
         $self->selected and $url .= '?'.$self->name.'_node='.$node;
         $attr->{href} = $url;
      }
      else { $attr->{href} = '#top' }

      my $link = $hacc->a( $attr, $text );

      $attr = { class => 'tips', title => $self->hint_title.$TTS.$tip };
      $link = $hacc->span( $attr, $link );
      $attr = { class => $prefix.($last ? '_last' : $NUL).'_fill' };

      my $fill = $args->{fill}.($self->node_count > 1
                                ? $hacc->span( $attr, $SPC ) : $NUL);

      ref $data eq 'HASH'
         and $list = $self->traverse( { data => $data, fill => $fill } );

      my $class = $prefix.($list ? '_node' : '_leaf');
      my $ctrl  = ($fill
                   ? $hacc->span( { class => $class.'_ctrl' }, $SPC ) : $NUL);
      my $icon  = $hacc->span( { class => $class.'_icon' }, $SPC );
      my $item  = ($args->{fill} ? $args->{fill} : $NUL).$ctrl.$icon.$link;

      $last and $class .= '_last'; $list and $class .= '_open';

      $item  = $hacc->dt( { class => $class, id => $node }, $item );
      $html .= $item.($list ? $hacc->dd( { class => $class }, $list ) : $NUL);
   }

   return $hacc->dl( $attr, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
