package HTML::FormWidgets::Tree;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use Readonly;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $NUL => q();

sub _render {
   my ($self, $ref)  = @_; my ($jscript, $name, @root);

   @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   if (defined $root[1]) {
      return $self->elem->span( { class => q(error) },
                                'Your tree has more than one root' );
   }

   $ref = { data => $self->data, parent => $NUL, prevKey => $NUL, root => 1 };
   $jscript = $self->elem->script( { language => q(JavaScript) },
                                   $self->scanHash( $ref ) );

   return $self->elem->div( { class => q(tree) }, $jscript );
}

sub nodeId { return shift->{nodeId}++ }

sub scanHash {
   my ($self, $ref) = @_;
   my ($data, $jscript, $key, @keys, $newKey, $node, $openIcon, $ref1);
   my ($shutIcon, $text, $tip, $url);

   $jscript = $NUL;
   @keys    = grep { ! m{ \A _ }mx} keys %{ $ref->{data} };

   for $key (sort { lc $a cmp lc $b } @keys) {
      $newKey   = $ref->{prevKey} ? $ref->{prevKey}.$SUBSEP.$key : $key;
      $data     = $ref->{data}->{ $key };
      $node     = $self->nodeId;
      $openIcon = $NUL;
      $shutIcon = $NUL;
      $tip      = $NUL;
      $url      = $self->url;

      if (ref $data eq q(HASH)) {
         $node     = $data->{_node_id } || $self->nodeId;
         $openIcon = $data->{_openIcon} || $NUL;
         $shutIcon = $data->{_shutIcon} || $NUL;
         $tip      = $data->{_tip     } || $NUL;
         $url      = $data->{_url     } || $self->url;
      }

      if ($self->node && ($self->node eq $node) && $self->select) {
         $shutIcon = $openIcon = $self->select;
      }

      $url  = $self->base.$url if ($url !~ m{ \A http: }mx);
      $url .= '?node='.$node;
      $self->id2key->{ $node }    = $newKey;
      $self->key2id->{ $newKey }  = $node;
      $self->key2url->{ $newKey } = $url;

      if ($ref->{root}) {
         $jscript  = 'if (document.getElementById) {'."\n";
         $jscript .= 'var '.$node.' = new WebFXTree("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.setBehavior("'.$self->behaviour.'");'."\n";
         $jscript .= $node.'.target = "'.$self->target.'"; '."\n"
            if ($self->target);
         $jscript .= $node.'.icon = "'.$shutIcon.'"; '."\n"     if ($shutIcon);
         $jscript .= $node.'.openIcon = "'.$openIcon.'"; '."\n" if ($openIcon);
      }
      else {
         $jscript .= 'var '.$node.' = new WebFXTreeItem("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.target = "'.$self->target.'"; '."\n"
            if ($self->target);
         $jscript .= $node.'.icon = "'.$shutIcon.'"; '."\n"     if ($shutIcon);
         $jscript .= $node.'.openIcon = "'.$openIcon.'"; '."\n" if ($openIcon);
         $jscript .= $ref->{parent}.'.add('.$node.'); '."\n";
      }

      if (ref $data eq 'HASH') {
         $ref1 = { data    => $data,
                   parent  => $node,
                   prevKey => $self->id2key->{ $node },
                   root    => 0 };
         $jscript .= $self->scanHash( $ref1 ); # Recurse
      }
   }

   if ($ref->{root}) {
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
