package HTML::FormWidgets::Tree;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);
use English qw(-no_match_vars);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(base behaviour data node_count id2key
                              key2id key2url node select target url) );

my $NUL = q();

sub init {
   my ($self, $args) = @_;

   $self->base(       $NUL );
   $self->behaviour(  q(classic) );
   $self->data(       {} );
   $self->id2key(     {} );
   $self->key2id(     {} );
   $self->key2url(    {} );
   $self->node(       undef );
   $self->node_count( 0 );
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
      return $self->hacc->span( { class => q(error) },
                                'Your tree has more than one root' );
   }

   $ref = { data => $self->data, parent => $NUL, prev_key => $NUL };
   $jscript = $self->hacc->script( { type => 'text/javascript' },
                                   $self->scan_hash( $ref ) );

   return $self->hacc->div( { class => q(tree) }, $jscript );
}

sub node_id { return shift->{node_count}++ }

sub scan_hash {
   my ($self, $args) = @_;
   my ($data, $jscript, $key, @keys, $new_key, $node, $open_icon);
   my ($shut_icon, $text, $tip, $url);

   $jscript = $NUL;
   @keys    = grep { !m{ \A _ }mx } keys %{ $args->{data} };

   for $key (sort { lc $a cmp lc $b } @keys) {
      $new_key   = $args->{prev_key} ? $args->{prev_key}.$SUBSEP.$key : $key;
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
         $url       = $data->{_url     } || $url;
      }

      if ($self->node && ($self->node eq $node) && $self->select) {
         $shut_icon = $open_icon = $self->select;
      }

      $url  = $self->base.$url unless ($url =~ m{ \A http: }mx);
      $url .= '?node='.$node;
      $self->id2key->{  $node    } = $new_key;
      $self->key2id->{  $new_key } = $node;
      $self->key2url->{ $new_key } = $url;

      if ($args->{parent}) {
         $jscript .= 'var '.$node.' = new Tree.Branch("'.$key.'", "';
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
      else {
         $jscript  = "\n".'var '.$node.' = new Tree.Trunk("'.$key.'", "';
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

      if (ref $data eq q(HASH)) {
         $jscript .= $self->scan_hash
            ( { data     => $data, parent => $node,
                prev_key => $self->id2key->{ $node } } ); # Recurse
      }
   }

   unless ($args->{parent}) {
      $jscript .= 'document.write('.$node.');'."\n";
      $jscript .= $self->node.'.focus();'."\n" if ($self->node);
   }

   return $jscript;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
