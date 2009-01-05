package HTML::FormWidgets::Tree;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);
use English qw(-no_match_vars);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(base behaviour data node_count
                              selected target url) );

my $NUL = q();

sub init {
   my ($self, $args) = @_;

   $self->base(       $NUL );
   $self->behaviour(  q(classic) );
   $self->data(       {} );
   $self->selected(   undef );
   $self->target(     q() );
   $self->url(        undef );
   $self->NEXT::init( $args );

   return;
}

sub _render {
   my ($self, $args) = @_;

   my @root = grep { ! m{ \A _ }mx } keys %{ $self->data };

   if (defined $root[1]) {
      return $self->hacc->span
         ( { class => q(error) }, 'Your tree has more than one root' );
   }

   $self->node_count( 0 );

   my $code    = $self->scan_hash(    { data   => $self->data,
                                        parent => $NUL, prev_key => $NUL } );
   my $jscript = $self->hacc->script( { type   => 'text/javascript' }, $code );

   return $self->hacc->div( { class => q(tree) }, $jscript );
}

sub node_id {
   my $self = shift; return $self->name.q(_node_).$self->{node_count}++;
}

sub scan_hash {
   my ($self, $args) = @_; my $jscript = $NUL; my $node;

   my @keys = grep { !m{ \A _ }mx } keys %{ $args->{data} };

   for my $key (sort { lc $a cmp lc $b } @keys) {
      $node         = $self->node_id;

      my $new_key   = $args->{prev_key}
                    ? $args->{prev_key}.$SUBSEP.$key : $key;
      my $data      = $args->{data}->{ $key };
      my $open_icon = $NUL;
      my $shut_icon = $NUL;
      my $tip       = $NUL;
      my $url       = $self->url;

      if (ref $data eq q(HASH)) {
         $node      = $data->{_node_id } || $node;
         $open_icon = $data->{_openIcon} || $open_icon;
         $shut_icon = $data->{_shutIcon} || $shut_icon;
         $tip       = $data->{_tip     } || $tip;
         $url       = $data->{_url     } || $url;
      }

      $url  = $self->base.$url unless ($url =~ m{ \A http: }mx);

      $url .= q(?).$self->name.q(_node=).$node if ($self->selected);

      unless ($args->{parent}) {
         $jscript  = "\n".'var '.$node.' = new Tree.Trunk("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
         $jscript .= $node.'.setBehavior("'.$self->behaviour.'");'."\n";
      }
      else {
         $jscript .= 'var '.$node.' = new Tree.Branch("'.$key.'", "';
         $jscript .= $url.'", "'.$tip.'");'."\n";
      }

      if ($self->target) {
         $jscript .= $node.'.target = "'.$self->target.'"; '."\n";
      }

      if ($shut_icon) {
         $jscript .= $node.'.icon = "'.$shut_icon.'"; '."\n";
      }

      if ($open_icon) {
         $jscript .= $node.'.openIcon = "'.$open_icon.'"; '."\n";
      }

      if ($self->selected && ($self->selected eq $node)) {
         $jscript .= $node.'.selected = true; '."\n";
      }

      if ($args->{parent}) {
         $jscript .= $args->{parent}.'.add('.$node.'); '."\n";
      }

      if (ref $data eq q(HASH)) { # Recurse
         $jscript .= $self->scan_hash
            ( { data => $data, parent => $node, prev_key => $new_key } );
      }
   }

   unless ($args->{parent}) {
      $jscript .= 'document.write('.$node.');'."\n";
      $jscript .= $self->selected.'.focus();'."\n" if ($self->selected);
   }

   return $jscript;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
