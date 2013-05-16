# @(#)$Ident: ;

package HTML::FormWidgets::Columnizer;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev: 0 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(column_class columns data hclass
                              max_width para_lead) );

sub init {
   my ($self, $args) = @_;

   $self->column_class( q()              );
   $self->columns     ( 1                );
   $self->data        ( { values => [] } );
   $self->hclass      ( q()              );
   $self->max_width   ( 90               );
   $self->para_lead   ( 30               );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $data  = $self->data; my $hacc = $self->hacc;

   my $plist = []; my $tsize = 0; my $nparas = 0;

   for my $val (@{ $data->{values} }) {
      my $psize = 0; my $para = {}; my ($class, $text);

      if ($text = $val->{heading}) {
         $psize += length $text;
         $class  = defined $val->{hclass} ? $val->{hclass} : $self->hclass;
         $para->{header}->{args} = $class ? { class => $class } : {};
         $para->{header}->{text} = $text;
      }

      if ($text = $val->{text}) {
         $psize += length (ref $text ? $text->{text} : $text);

         if (ref $text) { $para->{body}->{widget} = $text }
         else {
            $class = defined $val->{class} ? $val->{class} : $self->class;
            $para->{body}->{args  }->{class} = $class if ($class);
            $para->{body}->{widget}->{text } = $text;
         }
      }

      $para->{size} = $psize;
      push @{ $plist }, $para;
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
      my $psize   = $plist->[ $pno ]->{size};
      my $is_over = $size + $psize >= $quotient ? 1 : 0;

      if ($paras and $is_over and $col < $self->columns) {
         my $widget      = $plist->[ $pno ]->{body}->{widget};
         my $text        = $widget->{text};
         my ($car, $cdr) = $self->_split( $text, $quotient - $size );

         if ($car) {
            $widget->{text} = $car;
            $paras .= $self->_render_para( $hacc, $plist->[ $pno ] );
            delete $plist->[ $pno ]->{header};
         }

         $html .= $self->_render_column( $hacc, $width, $paras ); $col++;

         if ($cdr) {
            $widget->{text} = $cdr;
            $paras = $self->_render_para( $hacc, $plist->[ $pno ] );
            $size  = $self->para_lead + length $cdr;
         }
         else { $paras = q(); $size = 0 }
      }
      else {
         $paras .= $self->_render_para( $hacc, $plist->[ $pno ] );
         $size  += $self->para_lead + $psize;
      }

      $pno++;
   }

   $html .= $self->_render_column( $hacc, $width, $paras ) if ($paras);

   return $html;
}

sub _render_column {
   my ($self, $hacc, $width, $paras) = @_;

   my $args = $self->column_class ? { class => $self->column_class } : {};

   $args->{style} = 'width: '.$width.'%;' if ($self->columns > 1);

   return "\n".$hacc->div( $args, $paras );
}

sub _render_para {
   my ($self, $hacc, $para) = @_; my $text = q();

   if (my $header = $para->{header}) {
      $text .= "\n".$hacc->span( $header->{args},
                                 $self->inflate( $header->{text} ) );
   }

   my $body    = $para->{body};
   my $widget  = $body->{widget} || { text => $self->loc( 'Text missing' ) };
   my $content = $widget->{type} ? $self->inflate( $widget ) : $widget->{text};

   if (my $args = $body->{args}) { $text .= $hacc->p( $args, $content ) }
   else { $text .= $hacc->p( $content ) }

   return $text;
}

sub _split {
   my ($self, $text, $split) = @_;

   my $car   = substr $text, 0, $split;
   my $cdr   = substr $text, $split;
   my ($end) = $car =~ m{ \s+ (\S+) \z }mx;

   if ($end) {
      $car = substr $car, 0, (length $car) - (length $end);
      $cdr = $end.$cdr;
   }

   # Widows and orphans
   if (2 * $self->para_lead > length $car) { $car = q(); $cdr = $text }
   if ($self->para_lead / 2 > length $cdr) { $car = $text; $cdr = q() }

   return ($car, $cdr);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
