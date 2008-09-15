package HTML::FormWidgets::Note;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($self, $ref) = @_; my $text;

   $ref           = { class => q(note) };
   $ref->{style} .= 'text-align: '.$self->align.q(;) if ($self->align);
   $ref->{style} .= ' width: '.$self->width.q(;)     if ($self->width);

   ($text = $self->msg( $self->name ) || $self->text || q())
      =~ s{ \A \n }{}msx;

   return $self->elem->div( $ref, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
