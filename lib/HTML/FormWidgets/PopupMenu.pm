# @(#)$Id$

package HTML::FormWidgets::PopupMenu;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(labels values) );

sub init {
   my ($self, $args) = @_;

   $self->labels( undef );
   $self->values( [] );
   return;
}

sub render_field {
   my ($self, $args)   = @_;

   $self->class =~ m{ chzn-select }msx
      and push @{ $self->optional_js }, qw(chosen.js);

   $args->{class   } .= q( ).($self->class || q(ifield));
   $args->{labels  }  = $self->labels   if ($self->labels);
   $args->{onchange}  = $self->onchange if ($self->onchange);
   $args->{values  }  = $self->values;

   return $self->hacc->popup_menu( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
