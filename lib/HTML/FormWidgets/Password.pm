# @(#)$Id$

package HTML::FormWidgets::Password;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.18.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(subtype width) );

sub init {
   my ($self, $args) = @_;

   $self->subtype( q(normal) );
   $self->width  ( 20        );
   return;
}


sub render_field {
   my ($self, $args) = @_;

   my $hacc        =  $self->hacc;
   my $subtype     =  $self->subtype;
   my $reveal      =  $subtype =~ m{ reveal }msx ? 1 : 0;

   if ($reveal) {
      my $id2      =  $args->{id}; $id2 =~ s{ 1 }{2}mx;
      my $options  = { event  => "[ 'focus', 'blur' ]",
                       method => "[ 'show_password', 'hide_password' ]" };

      $self->add_literal_js( 'inputs', $self->id, $options );
      $self->add_literal_js( 'inputs', $id2, $options );
   }

   $args->{class} .=  q( ifield).($reveal ? q( reveal) : q());
   $args->{size }  =  $self->width;

   my $html        =  $hacc->password_field( $args );

   $subtype        =~ m{ verify }msx or return $html;
   $html          .=  $hacc->span( { class => q(prompt) },
                                   $self->loc( q(vPasswordPrompt) ) );
   $args->{name}   =~ s{ 1 }{2}mx; $args->{id} =~ s{ 1 }{2}mx;
   $html          .=  $hacc->password_field( $args );
   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
