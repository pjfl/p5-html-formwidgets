package HTML::FormWidgets::Label;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my ($markup, $text);

   $ref->{class} = q(label) unless ($self->class);

   ($text = $self->msg( $self->name ) || $self->text || q())
      =~ s{ \A \n }{}msx;

   if ($text && $self->dropcap) {
      if ($text =~ m{ \A (\<[A-Za-z0-9]+\>) }mx) {
         $markup  = $1;
         $markup .= $self->elem->span( { class => q(dropcap) },
                                     substr $text, length $1, 1 );
         $markup .= substr $text, (length $1) + 1;
      }
      else {
         $markup  = $self->elem->span( { class => q(dropcap) },
                                     substr $text, 0, 1 );
         $markup .= substr $text, 1;
      }

      $text = $markup;
   }

   return $text;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
