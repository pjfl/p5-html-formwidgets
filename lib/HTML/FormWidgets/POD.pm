# @(#)$Id$

package HTML::FormWidgets::POD;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

use Pod::Html;

__PACKAGE__->mk_accessors( qw(css src tempdir tempfile title) );

sub _init {
   my ($self, $args) = @_;

   $self->css     ( undef );
   $self->src     ( undef );
   $self->tempdir ( undef );
   $self->tempfile( undef );
   $self->title   ( undef );
   return;
}

sub _render {
   my ($self, $args) = @_; my $line;

   no warnings; ## no critic

   my $body = 0; my $html = q(); my $tmp = $self->tempfile;

   pod2html( '--backlink='.$self->loc( 'Back to Top' ),
             '--cachedir='.$self->tempdir,
             '--css='.$self->css,
             '--infile='.$self->src,
             '--outfile='.$tmp->pathname,
             '--quiet',
             '--title='.$self->title );

   while (defined ($line = $tmp->getline) ) {
      $body  = 0     if ($line =~ m{ \</body }mx);
      $html .= $line if ($body);
      $body  = 1     if ($line =~ m{ \<body }mx);
   }

   return $html;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
