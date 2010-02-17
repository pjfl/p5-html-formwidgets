# @(#)$Id$

package HTML::FormWidgets::Tree;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);

__PACKAGE__->mk_accessors( qw(base behaviour data node_count
                              selected static target url) );

my $NUL = q();

sub init {
   my ($self, $args) = @_;

   $self->base     ( $NUL       );
   $self->behaviour( q(classic) );
   $self->data     ( {}         );
   $self->selected ( undef      );
   $self->static   ( $NUL       );
   $self->target   ( q()        );
   $self->url      ( undef      );

   push @{ $self->optional_js }, q(tree.js);
   return;
}

sub render_field {
   my $self = shift;
   my $hacc = $self->hacc;
   my @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   defined $root[1] and return $hacc->span
      ( { class => q(error) }, 'Your tree has more than one root' );

   $self->node_count( 0 );

   my $args  = { class   => q(action tips),
                 onclick => $self->name.'_node_0.expandAll()',
                 src     => $self->static.q(images/expand.png) };
   my $html  = $hacc->img( $args );
      $args  = { class   => q(action tips),
                 onclick => $self->name.'_node_0.collapseAll()',
                 src     => $self->static.q(images/collapse.png) };
      $html .= $hacc->img( $args );
      $args  = { class => q(tree_controls) };
      $html  = $hacc->span( $args, $html );
      $args  = { class => q(tree), id => $self->id };
      $html .= $hacc->span( $args );
      $args  = { data => $self->data, parent => $NUL, prev_key => $NUL };
   my $code  = __wrap_cdata( $self->scan_hash( $args ) );

   return $html."\n".$hacc->script( { type => 'text/javascript' }, $code );
}

sub node_id {
   my $self = shift; return $self->name.q(_node_).$self->{node_count}++;
}

sub scan_hash {
   my ($self, $args) = @_; my $script = $NUL; my $node;

   my @keys = grep { !m{ \A _ }mx } keys %{ $args->{data} };

   for my $key (sort { lc $a cmp lc $b } @keys) {
      $node = $self->node_id;

      my $new_key   = $args->{prev_key}
                    ? $args->{prev_key}.$SUBSEP.$key : $key;
      my $data      = $args->{data}->{ $key };
      my $open_icon = $NUL;
      my $shut_icon = $NUL;
      my $text      = $key;
      my $tip       = $NUL;
      my $url       = $self->url;

      if (ref $data eq q(HASH)) {
         $node      = $data->{_node_id } || $node;
         $open_icon = $data->{_openIcon} || $open_icon;
         $shut_icon = $data->{_shutIcon} || $shut_icon;
         $text      = $data->{_text    } || $text;
         $tip       = $data->{_tip     } || $tip;
         $url       = $data->{_url     } || $url;
      }

      $url  = $self->base.$url unless ($url =~ m{ \A http: }mx);

      $url .= q(?).$self->name.q(_node=).$node if ($self->selected);

      unless ($args->{parent}) {
         $script  = "\n".'var '.$node.' = new Tree.Trunk("'.$text.'", "';
         $script .= $url.'", "'.$tip.'");'."\n";
         $script .= $node.'.setBehavior("'.$self->behaviour.'");'."\n";
      }
      else {
         $script .= 'var '.$node.' = new Tree.Branch("'.$text.'", "';
         $script .= $url.'", "'.$tip.'");'."\n";
      }

      if ($self->target) {
         $script .= $node.'.target = "'.$self->target.'"; '."\n";
      }

      if ($shut_icon) {
         $script .= $node.'.icon = "'.$shut_icon.'"; '."\n";
      }

      if ($open_icon) {
         $script .= $node.'.openIcon = "'.$open_icon.'"; '."\n";
      }

      if ($self->selected && ($self->selected eq $node)) {
         $script .= $node.'.selected = true; '."\n";
      }

      if ($args->{parent}) {
         $script .= $args->{parent}.'.add('.$node.'); '."\n";
      }

      if (ref $data eq q(HASH)) { # Recurse
         $script .= $self->scan_hash
            ( { data => $data, parent => $node, prev_key => $new_key } );
      }
   }

   if (not $args->{parent} and $node) {
      $script .= '$( "'.$self->id.'" ).setHTML('.$node.' + "" );'."\n";
      $script .= $self->selected.'.focus();'."\n" if ($self->selected);
   }

   return $script;
}

sub __wrap_cdata {
   my $code = shift; return q(//<![CDATA[).$code.q(//]]>);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
