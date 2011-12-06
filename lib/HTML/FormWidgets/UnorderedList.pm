# @(#)$Id$

package HTML::FormWidgets::UnorderedList;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config data item_class) );

my $NBSP = '&#160;';

sub init {
   my ($self, $args) = @_;

   $self->config    ( {} );
   $self->class     ( q(plain) );
   $self->data      ( [] );
   $self->item_class( undef );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc; my ($data, $html);

   ($data = $self->data and $data->[ 0 ]) or return; my $js_args = {};

   for (grep { defined $self->config->{ $_ } } keys %{ $self->config }) {
      $js_args->{ $_ } = '"'.$self->config->{ $_ }.'"';
   }

   $self->add_literal_js( q(lists), $args->{id}, $js_args );

   my $item_args = $self->item_class ? { class => $self->item_class } : {} ;

   for my $item (@{ $data }) {
      $html .= $hacc->li( $item_args,
                          $self->inflate( $item->{content} || $NBSP ) );
   }

   return $hacc->ul( { class => $self->class, id => $args->{id} }, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
