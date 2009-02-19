package HTML::FormWidgets::Slider;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/g );

__PACKAGE__->mk_accessors( qw(mode offset range snap steps wheel) );

sub _init {
   my ($self, $args) = @_;

   $self->mode (  q(horizontal) );
   $self->offset( 0 )
   $self->range(  0 );
   $self->snap(   1 )
   $self->steps(  100 );
   $self->wheel(  1 );
   return;
}

sub _render {
   my ($self, $args) = @_; my ($hacc, $html, $text);

#	new Slider(el, el.getElement('.knob'), {
#		onChange: function(value){
#			// Everytime the value changes, we change the font of an element
#			font.setStyle('font-size', value);
#		}
#	}).set(font.getStyle('font-size').toInt());
   $hacc  = $self->hacc;
   $text  = 'var el = $( "'.$args->{name}.'")';
   $text .= 'new Slider( el, el.getElement( ".knob" ), {';
   $text .= '   mode   : "'.$self->mode.'", ';
   $text .= '   offset : "'.$self->offset.'", ';
   $text .= '   range  : "'.$self->range.'", ';
   $text .= '   snap   : '.($self->snap ? 'true' : 'false' ).', ';
   $text .= '   steps  : "'.$self->steps.'", ';
   $text .= '   wheel  : '.($self->wheel ? 'true' : 'false' ).' } );';
   $html .= $hacc->script( { type => q(text/javascript) }, $text );
   return $html;
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets::Slider - Dragable slider

=head1 Version

0.1.$Revision$

=head1 Synopsis

=head1 Description

Dragable slider that returns an integer value

=head1 Subroutines/Methods

=head1 Diagnostics

=head1 Configuration and Environment

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
