package HTML::FormWidgets::Note;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my $text;

   $ref           = { class => q(note) };
   $ref->{style} .= 'text-align: '.$me->palign.'; ' if ($me->palign);
   $ref->{style} .= 'width: '.$me->pwidth.q(;)      if ($me->pwidth);

   ($text = $me->msg( $me->name ) || $me->text || q()) =~ s{ \A \n }{}msx;

   return $me->elem->div( $ref, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
