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
   my ($me, $ref)  = @_; my ($jscript, $name, @root);

   @root = grep { ! m{ \A _ }mx } keys %{ $me->data };

   if (defined $root[1]) {
      return $me->elem->span( { class => 'error' },
                              'Your tree has more than one root' );
   }

   $ref = { data => $me->data, parent => $NUL, prevKey => $NUL, root => 1 };
   $jscript = $me->elem->script( { language => 'JavaScript' },
                                 $me->scanHash( $ref ) );

   return $me->elem->div( { class => 'tree' }, $jscript );
}

sub nodeId { return shift->{nodeId}++ }

sub scanHash {
   my ($me, $ref) = @_;
   my ($data, $jscript, $key, @keys, $newKey, $node, $openIcon, $ref1);
   my ($shutIcon, $text, $tip, $url);

   $jscript = $NUL;
   @keys    = grep { ! m{ \A _ }mx} keys %{ $ref->{data} };

   for $key (sort { lc $a cmp lc $b } @keys) {
      $newKey   = $ref->{prevKey} ? $ref->{prevKey}.$SUBSEP.$key : $key;
      $data     = $ref->{data}->{ $key };
      $node     = $me->nodeId;
      $openIcon = $NUL;
      $shutIcon = $NUL;
      $tip      = $NUL;
      $url      = $me->url;

      if (ref $data eq 'HASH') {
         $node     = $data->{_node_id } || $me->nodeId;
         $openIcon = $data->{_openIcon} || $NUL;
         $shutIcon = $data->{_shutIcon} || $NUL;
         $tip      = $data->{_tip     } || $NUL;
         $url      = $data->{_url     } || $me->url;
      }

      if ($me->node && ($me->node eq $node) && $me->select) {
         $shutIcon = $openIcon = $me->select;
      }

      $url  = $me->base.$url if ($url !~ m{ \A http: }mx);
      $url .= '?node='.$node;
      $me->id2key->{ $node }    = $newKey;
      $me->key2id->{ $newKey }  = $node;
      $me->key2url->{ $newKey } = $url;

      if ($ref->{root}) {
         $jscript  = 'if (document.getElementById) {'."\n";
         $jscript .= 'var '.$node.' = new WebFXTree("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.setBehavior("'.$me->behaviour.'");'."\n";
         $jscript .= $node.'.target = "'.$me->target.'"; '."\n"
            if ($me->target);
         $jscript .= $node.'.icon = "'.$shutIcon.'"; '."\n"     if ($shutIcon);
         $jscript .= $node.'.openIcon = "'.$openIcon.'"; '."\n" if ($openIcon);
      }
      else {
         $jscript .= 'var '.$node.' = new WebFXTreeItem("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.target = "'.$me->target.'"; '."\n"
            if ($me->target);
         $jscript .= $node.'.icon = "'.$shutIcon.'"; '."\n"     if ($shutIcon);
         $jscript .= $node.'.openIcon = "'.$openIcon.'"; '."\n" if ($openIcon);
         $jscript .= $ref->{parent}.'.add('.$node.'); '."\n";
      }

      if (ref $data eq 'HASH') {
         $ref1 = { data    => $data,
                   parent  => $node,
                   prevKey => $me->id2key->{ $node },
                   root    => 0 };
         $jscript .= $me->scanHash( $ref1 ); # Recurse
      }
   }

   if ($ref->{root}) {
      $jscript .= 'document.write('.$node.');'."\n".'}'."\n";
      $jscript .= $me->node.'.focus();'."\n" if ($me->node);
   }

   return $jscript;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
