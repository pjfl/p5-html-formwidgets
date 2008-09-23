package HTML::FormWidgets::Tree;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use Readonly;

use version; our $VERSION = qv( sprintf '0.2.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $NUL => q();

__PACKAGE__->mk_accessors( qw(base behaviour data node_count id2key
                              key2id key2url node select target url) );

sub init {
   my ($self, $args) = @_;

   $self->base(       $NUL );
   $self->behaviour(  q(classic) );
   $self->data(       {} );
   $self->node_count( 0 );
   $self->id2key(     {} );
   $self->key2id(     {} );
   $self->key2url(    {} );
   $self->node(       undef );
   $self->select(     undef );
   $self->target(     q() );
   $self->url(        undef );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $ref)  = @_; my ($jscript, $name, @root);

   @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   if (defined $root[1]) {
      return $self->elem->span( { class => q(error) },
                                'Your tree has more than one root' );
   }

   $ref = { data => $self->data, parent => $NUL, prevKey => $NUL, root => 1 };
   $jscript = $self->elem->script( { language => q(JavaScript) },
                                   $self->scan_hash( $ref ) );

   return $self->elem->div( { class => q(tree) }, $jscript );
}

sub node_id { return shift->{node_count}++ }

sub scan_hash {
   my ($self, $args) = @_;
   my ($data, $jscript, $key, @keys, $new_key, $node, $open_icon);
   my ($shut_icon, $text, $tip, $url);

   $jscript = $NUL;
   @keys    = grep { !m{ \A _ }mx } keys %{ $args->{data} };

   for $key (sort { lc $a cmp lc $b } @keys) {
      $new_key   = $args->{prevKey} ? $args->{prevKey}.$SUBSEP.$key : $key;
      $data      = $args->{data}->{ $key };
      $node      = $self->node_id;
      $open_icon = $NUL;
      $shut_icon = $NUL;
      $tip       = $NUL;
      $url       = $self->url;

      if (ref $data eq q(HASH)) {
         $node      = $data->{_node_id } || $node;
         $open_icon = $data->{_openIcon} || $NUL;
         $shut_icon = $data->{_shutIcon} || $NUL;
         $tip       = $data->{_tip     } || $NUL;
         $url       = $data->{_url     } || $self->url;
      }

      if ($self->node && ($self->node eq $node) && $self->select) {
         $shut_icon = $open_icon = $self->select;
      }

      $url  = $self->base.$url if ($url !~ m{ \A http: }mx);
      $url .= '?node='.$node;
      $self->id2key->{  $node    } = $new_key;
      $self->key2id->{  $new_key } = $node;
      $self->key2url->{ $new_key } = $url;

      if ($args->{root}) {
         $jscript  = 'if (document.getElementById) {'."\n";
         $jscript .= 'var '.$node.' = new WebFXTree("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.setBehavior("'.$self->behaviour.'");'."\n";

         if ($self->target) {
            $jscript .= $node.'.target = "'.$self->target.'"; '."\n";
         }

         if ($shut_icon) {
            $jscript .= $node.'.icon = "'.$shut_icon.'"; '."\n";
         }

         if ($open_icon) {
            $jscript .= $node.'.openIcon = "'.$open_icon.'"; '."\n";
         }
      }
      else {
         $jscript .= 'var '.$node.' = new WebFXTreeItem("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";

         if ($self->target) {
            $jscript .= $node.'.target = "'.$self->target.'"; '."\n";
         }

         if ($shut_icon) {
            $jscript .= $node.'.icon = "'.$shut_icon.'"; '."\n";
         }

         if ($open_icon) {
            $jscript .= $node.'.openIcon = "'.$open_icon.'"; '."\n";
         }

         $jscript .= $args->{parent}.'.add('.$node.'); '."\n";
      }

      if (ref $data eq q(HASH)) {
         $jscript .= $self->scan_hash( { data    => $data,
                                         parent  => $node,
                                         prevKey => $self->id2key->{ $node },
                                         root    => 0 } ); # Recurse
      }
   }

   if ($args->{root}) {
      $jscript .= 'document.write('.$node.');'."\n".'}'."\n";
      $jscript .= $self->node.'.focus();'."\n" if ($self->node);
   }

   return $jscript;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
