# @(#)$Id$

package HTML::FormWidgets::Template;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use English qw(-no_match_vars);
use File::Spec;
use IO::File;

__PACKAGE__->mk_accessors( qw(templatedir) );

sub init {
   my ($self, $args) = @_;

   $self->templatedir( undef );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $path = File::Spec->catfile( $self->templatedir, $self->id.q(.tt) );

   -f $path or return "Not found $path";

   my $rdr = IO::File->new( $path, q(r) ) or return "Cannot read $path";

   my $content = do { local $RS = undef; <$rdr> }; $rdr->close();

   return $content;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
