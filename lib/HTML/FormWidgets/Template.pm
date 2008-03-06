package HTML::FormWidgets::Template;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use File::Spec::Functions;
use IO::All;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

sub _render {
   my ($me, $ref) = @_; my ($content, $path);

   $path = catfile( $me->templatedir, $me->id.'.tt' );

   return 'Not found '.$path unless (-f $path);

   unless ($content = io( $path )->slurp) {
      $content = 'Cannot read '.$path;
   }

   return $content;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
