# @(#)$Id$

package HTML::FormWidgets::Paragraphs;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.8.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(column_class data hclass) );

sub init {
   my ($self, $args) = @_;

   $self->column_class( q()              );
   $self->data        ( { values => [] } );
   $self->hclass      ( q()              );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $data = $self->data; my $hacc = $self->hacc; my $paras = q();

   for my $val (@{ $data->{values} }) {
      my ($class, $text);

      if ($text = $val->{heading}) {
         $class  = defined $val->{hclass} ? $val->{hclass} : $self->hclass;
         $paras .= "\n".$hacc->div( $class ? { class => $class } : {},
                                     $self->inflate( $text ) );
      }

      $text   = $val->{text} && ref $val->{text}
              ? $self->inflate( $val->{text} )
              : $val->{text} || $self->loc( 'Text missing' );
      $class  = defined $val->{class} ? $val->{class} : $self->class;
      $args   = $class ? { class => $class } : {};
      $paras .= $hacc->p( $args, $text );
   }

   $args = $self->column_class ? { class => $self->column_class } : {};

   return "\n".$hacc->div( $args, $paras );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
