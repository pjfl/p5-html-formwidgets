package HTML::FormWidgets::Template;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

use English qw( -no_match_vars );
use File::Spec;
use IO::File;

__PACKAGE__->mk_accessors( 'stash_key' );

sub init {
   my ($self, $args) = @_;

   $self->stash_key( 'template_data' );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $content;

   if ($self->text) { $content = $self->text }
   else {
      my $path = File::Spec->catfile( $self->options->{template_dir},
                                      $self->name.'.tt' );

      -f $path or return "Path ${path} not found";

      my $rdr = IO::File->new( $path, 'r' ) or return "Path $path cannot read";

      $content = do { local $RS = undef; <$rdr> }; $rdr->close();
   }

   my $id = $self->id; my $key = $self->stash_key;

   return "[% ref = ${key}.${id}; %]\n${content}";
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
