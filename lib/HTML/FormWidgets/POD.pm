package HTML::FormWidgets::POD;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

use Pod::Hyperlink::BounceURL;
use Pod::Xhtml;

__PACKAGE__->mk_accessors( qw( src title url ) );

sub init {
   my ($self, $args) = @_;

   $self->container( 0       );
   $self->src      ( undef   );
   $self->title    ( undef   );
   $self->url      ( '%s/%s' );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $hacc = $self->hacc;

   my $heading     = $hacc->a( { id => 'podtop' } ).$hacc->h1( $self->title );
   my $link_parser = Pod::Hyperlink::BounceURL->new;

   $link_parser->configure( URL => $self->url );
   $args = { class => 'toplink', href => '#podtop' };

   my $top_link = $hacc->a( $args, $self->loc( 'Back to Top' ) );
   my $top_para = $hacc->p( { class => 'toplink' }, $top_link );
   my $parser   = Pod::Xhtml->new( FragmentOnly => 1,
                                   LinkParser   => $link_parser,
                                   StringMode   => 1,
                                   TopHeading   => 2,
                                   TopLinks     => $top_para, );

   $parser->parse_from_file( $self->src );

   return $heading.$parser->asString;
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
