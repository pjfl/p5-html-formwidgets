# @(#)$Ident: PopupMenu.pm 2013-05-16 14:21 pjf ;

package HTML::FormWidgets::PopupMenu;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.20.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(classes labels values) );

sub init {
   my ($self, $args) = @_;

   $self->classes( undef );
   $self->labels ( undef );
   $self->values ( [] );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $self->class =~ m{ chzn-select }msx
      and $self->add_optional_js( q(chosen.js) );

   $args->{class} .= q( ).($self->class || q(ifield));
   $self->classes  and $args->{classes } = $self->classes;
   $self->onchange and $args->{onchange} = $self->onchange;

   if ($self->labels) {
      my $labels = $args->{labels} = $self->labels;

      $args->{values} = [ sort {
         ($labels->{ $a } || q())
            cmp ($labels->{ $b } || q()) } @{ $self->values } ];
   }
   else { $args->{values} = $self->values }

   return $self->hacc->popup_menu( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
