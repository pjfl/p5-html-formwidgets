package HTML::FormWidgets::Template;

# @(#)$Id$

use strict;
use warnings;
use base qw(HTML::FormWidgets);
use English qw(-no_match_vars);
use File::Spec::Functions;
use IO::File;

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(templatedir) );

sub init {
   my ($self, $args) = @_;

   $self->templatedir( undef );

   $self->NEXT::init( $args );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($content, $path, $rdr);

   $path = catfile( $self->templatedir, $self->id.q(.tt) );

   return 'Not found '.$path   unless (-f $path);
   return 'Cannot read '.$path unless ($rdr = IO::File->new( $path, q(r) ));

   $content = do { local $RS = undef; <$rdr> }; $rdr->close();

   return $content;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
