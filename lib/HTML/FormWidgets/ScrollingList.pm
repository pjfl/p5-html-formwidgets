# @(#)$Ident: ScrollingList.pm 2013-05-16 14:21 pjf ;

package HTML::FormWidgets::ScrollingList;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.21.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(height labels values) );

sub init {
   my ($self, $args) = @_;

   $self->class ( q(ifield) );
   $self->height( 10 );
   $self->labels( undef );
   $self->values( [] );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   $self->class =~ m{ chzn-select }msx
      and $self->add_optional_js( q(chosen.js) );

   $args->{class   } .= ($args->{class} ? q( ) : q()).$self->class;
   $args->{labels  }  = $self->labels   if ($self->labels);
   $args->{onchange}  = $self->onchange if ($self->onchange);
   $args->{size    }  = $self->height;
   $args->{values  }  = $self->values;

   return $self->hacc->scrolling_list( $args );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
