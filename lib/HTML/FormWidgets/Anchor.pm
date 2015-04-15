package HTML::FormWidgets::Anchor;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( config fhelp href imgclass target ) );

sub init {
   my ($self, $args) = @_;

   $self->class   ( 'anchor_button fade' );
   $self->config  ( undef    );
   $self->fhelp   ( q()      );
   $self->href    ( undef    );
   $self->imgclass( undef    );
   $self->target  ( undef    );
   $self->tiptype ( 'normal' );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   $self->id and $self->config
      and $self->add_literal_js( 'anchors', $self->id, $self->config );

   my $html = $self->imgclass
            ? $self->text
            ? $hacc->img ( { alt   => $self->fhelp,
                             class => $self->imgclass,
                             src   => $self->uri_for( $self->text ) } )
            : $hacc->span( { class => $self->imgclass } )
            : $self->text || $self->loc( 'link' );

   $self->href or return $html; delete $args->{name};

   $args->{class} = $self->class; $args->{href} = $self->uri_for( $self->href );

   defined $self->target and $args->{target} = $self->target;

   return $hacc->a( $args, $html );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:

