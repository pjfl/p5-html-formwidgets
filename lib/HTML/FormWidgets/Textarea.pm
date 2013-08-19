# @(#)$Ident: Textarea.pm 2013-05-16 14:20 pjf ;

package HTML::FormWidgets::Textarea;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.21.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(cols config rows) );

sub init {
   my ($self, $args) = @_;

   $self->cols  ( 60 );
   $self->config( undef );
   $self->rows  ( 1  );
   return;
}

sub render_field {
   my ($self, $args)  = @_;

   $self->id and $self->config
      and $self->add_literal_js( 'inputs', $self->id, $self->config );

   $args->{class} .= ($args->{class} ? q( ): q()).($self->class || q(ifield));

   $args->{cols }  = $self->cols; $args->{rows} = $self->rows;

   return $self->hacc->textarea( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
