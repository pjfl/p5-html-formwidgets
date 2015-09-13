package HTML::FormWidgets::Chooser;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( button_name config field
                               href subtype title value ) );

my $_stringify = sub {
   my $v = shift;

   return '{ '.(join ', ', map { "${_}: ".$v->{ $_ } } sort keys %{ $v }).' }';
};

sub init {
   my ($self, $args) = @_;

   $self->button_name( '_method' );
   $self->class      ( 'chooser_button fade submit' );
   $self->config     ( { height => 500, width => 500, x => 10, y => 10 } );
   $self->field      ( q() );
   $self->href       ( undef );
   $self->subtype    ( 'window' );
   $self->text       ( $self->loc( 'Choose' ) );
   $self->title      ( $self->loc( 'Select Item' ) );
   $self->value      ( lc $self->text );
   return;
}

sub render_field {
   my $self = shift; my $config = $self->config; my $hacc = $self->hacc;

   if ($self->subtype eq 'display') {
      $self->add_literal_js( 'anchors', $self->id, $config );

      my $html = $hacc->a( { class => $self->class,
                             href  => $self->uri_for( $self->href ),
                             id    => $self->id, }, q( ) );

      return $hacc->div( { class => 'chooser_panel',
                           id    => $self->id.'Disp' }, $html );
   }

   $config->{ $_ } = "'".($self->$_)."'" for (qw( field subtype ));

   $config->{button} = "'".$self->value."'";
   $config->{title } = "'".$self->title."'";

   my $js = { args   => "[ '".$self->href."', ".$_stringify->( $config )." ]",
              method => "'chooser'" };

   $self->add_literal_js( 'anchors', $self->id, $js );

   return $hacc->button( { class => $self->class,
                           id    => $self->id,
                           name  => $self->button_name,
                           value => $self->value, }, $self->text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
