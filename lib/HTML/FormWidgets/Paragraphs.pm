package HTML::FormWidgets::Paragraphs;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(column_class columns data hclass) );

sub _init {
   my ($self, $args) = @_;

   $self->column_class( q() );
   $self->columns(      1 );
   $self->data(         { values => [] } );
   $self->hclass(       q() );
   return;
}

sub _render {
   my ($self, $args) = @_;
   my ($class, $html, $para, $quotient, $size, $text, $width, $val);

   my $data = $self->data; my $hacc = $self->hacc;

   if ($self->columns > 1) {
      for $val (@{ $data->{values} }) {
         $size += length $val->{heading} if ($val->{heading});
         $size += length $val->{text}    if ($val->{text});
      }

      $quotient = int $size / $self->columns;
      $width    = int 90 / $self->columns;
   }

   $size = 0;

   for $val (@{ $data->{values} }) {
      if ($text = $val->{heading}) {
         $size += length $text;
         $class = defined $val->{hclass} ? $val->{hclass} : $self->hclass;
         $args  = $class ? { class => $class } : {};
         $para .= "\n".$hacc->span( $args, $self->inflate( $text ) );
      }

      if ($text = $val->{text}) {
         $class = defined $val->{class} ? $val->{class} : $self->class;
         $args  = $class ? { class => $class } : {};
         $size += length $text->{text};

         if ($text->{markdown}) { $para .= $self->inflate( $text ) }
         else { $para .= $hacc->p( $args, $self->inflate( $text ) ) }
      }

      next unless ($para);

      if ($quotient and $size >= $quotient) {
         $args  = $self->column_class ? { class => $self->column_class } : {};
         $args->{style} = 'width: '.$width.'%;';
         $html .= "\n".$hacc->div( $args, $para );
         $size  = 0; $para = q();
      }
   }

   if ($para) {
      unless ($quotient) { $html .= $para }
      else {
         $args  = $self->column_class ? { class => $self->column_class } : {};
         $args->{style} = 'width: '.$width.'%;';
         $html .= "\n".$hacc->div( $args, $para );
      }
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
