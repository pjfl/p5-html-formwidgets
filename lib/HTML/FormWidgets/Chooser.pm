# @(#)$Id$

package HTML::FormWidgets::Chooser;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.17.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(config field href subtype title) );

sub init {
   my ($self, $args) = @_;

   $self->class  ( q(chooser_button fade submit) );
   $self->config ( { height => 500, width => 500, x => 10, y => 10 } );
   $self->default( $self->loc( 'Choose' ) );
   $self->field  ( q() );
   $self->href   ( undef );
   $self->subtype( q(window) );
   $self->title  ( $self->loc( 'Select Item' ) );
   return;
}

sub render_field {
   my $self = shift; my $config = $self->config; my $hacc = $self->hacc;

   if ($self->subtype eq q(display)) {
      $self->add_literal_js( 'anchors', $self->id, $config );

      my $html = $hacc->a( { class => $self->class,
                             href  => $self->href,
                             id    => $self->id, }, q( ) );

      return $hacc->div( { class => q(chooser_panel),
                           id    => $self->id.q(Disp) }, $html );
   }

   $config->{ $_ } = "'".($self->$_)."'" for (qw(field subtype));

   $config->{button} = "'".$self->default."'";
   $config->{title } = "'".$self->title."'";

   my $js = { args   => "[ '".$self->href."', ".__stringify( $config )." ]",
              method => "'chooser'" };

   $self->add_literal_js( 'anchors', $self->id, $js );

   return $hacc->submit( { class => $self->class,
                           id    => $self->id,
                           name  => q(_method),
                           value => $self->default, } );
}

sub __stringify {
   my $hash = shift;

   return '{ '.(join ', ', map { "${_}: ".$hash->{ $_ } } keys %{ $hash }).' }';
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
