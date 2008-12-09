package HTML::FormWidgets::Paragraphs;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(column_class columns data hclass) );

sub init {
   my ($self, $args) = @_;

   $self->column_class( q() );
   $self->columns(      1 );
   $self->data(         { values => [] } );
   $self->hclass(       q() );
   $self->NEXT::init(   $args );
   return;
}

sub _render {
   my ($self, $args) = @_;
   my ($class, $html, $para, $quotient, $size, $text, $val);

   my $data = $self->data; my $hacc = $self->hacc;

   if ($self->columns > 1) {
      for $val (@{ $data->{values} }) {
         $size += length $val->{heading} if ($val->{heading});
         $size += length $val->{text}    if ($val->{text});
      }

      $quotient = int $size / $self->columns;
   }

   $size = 0;

   for $val (@{ $data->{values} }) {
      if ($text = $val->{heading}) {
         $size += length $text;
         $class = defined $val->{hclass} ? $val->{hclass} : $self->hclass;
         $args  = $class ? { class => $class } : {};
         $para .= "\n".$hacc->span( $args, $self->_inflate( $text ) );
      }

      if ($text = $val->{text}) {
         $size += length $text;
         $class = defined $val->{class} ? $val->{class} : $self->class;
         $args  = $class ? { class => $class } : {};
         $para .= $hacc->p( $args, $self->_inflate( $text ) );
      }

      next unless ($para);

      if ($quotient and $size >= $quotient) {
         $args  = $self->column_class ? { class => $self->column_class } : {};
         $html .= "\n".$hacc->div( $args, $para );
         $size  = 0; $para = q();
      }
      else { $html .= $para; $para = q() }
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
