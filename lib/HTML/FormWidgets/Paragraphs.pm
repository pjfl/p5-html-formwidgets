package HTML::FormWidgets::Paragraphs;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(column_class columns data hclass max_width) );

sub _init {
   my ($self, $args) = @_;

   $self->column_class( q()              );
   $self->columns     ( 1                );
   $self->data        ( { values => [] } );
   $self->hclass      ( q()              );
   $self->max_width   ( 90               );
   return;
}

sub _render {
   my ($self, $args) = @_;

   my $data  = $self->data; my $hacc = $self->hacc;

   my $plist = []; my $tsize = 0; my $nparas = 0;

   for my $val (@{ $data->{values} }) {
      my $psize = 0; my $para = q(); my ($class, $text);

      if ($text = $val->{heading}) {
         $psize += length $text;
         $class  = defined $val->{hclass} ? $val->{hclass} : $self->hclass;
         $args   = $class ? { class => $class } : {};
         $para  .= "\n".$hacc->span( $args, $self->inflate( $text ) );
      }

      if ($text = $val->{text}) {
         $psize += length (ref $text ? $text->{text} : $text);

         unless (ref $text and $text->{markdown}) {
            $class = defined $val->{class} ? $val->{class} : $self->class;
            $args  = $class ? { class => $class } : {};
            $para .= $hacc->p( $args, $self->inflate( $text ) );
         }
         else { $para .= $self->inflate( $text ) }
      }

      push @{ $plist }, { para => $para, size => $psize };
      $tsize += $psize;
      $nparas++;
   }

   my $width    = int $self->max_width / $self->columns;
   my $quotient = int $tsize / $self->columns;
   my $html     = q();
   my $paras    = q();
   my $size     = 0;
   my $pno      = 0;
   my $col      = 1;

   while ($pno < $nparas) {
      my $para    = $plist->[ $pno ]->{para};
      my $psize   = $plist->[ $pno ]->{size};
      my $is_over = $size + $psize >= $quotient ? 1 : 0;

      if ($paras and $is_over and $col < $self->columns) {
         $html .= $self->_add_column( $hacc, $width, $paras );
         $paras = $para; $size = $psize;
         $col++;
      }
      else { $paras .= $para; $size += $psize }

      $pno++;
   }

   $html .= $self->_add_column( $hacc, $width, $paras ) if ($paras);

   return $html;
}

sub _add_column {
   my ($self, $hacc, $width, $paras) = @_;

   my $args = $self->column_class ? { class => $self->column_class } : {};

   $args->{style} = 'width: '.$width.'%;' if ($self->columns > 1);

   return "\n".$hacc->div( $args, $paras );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
