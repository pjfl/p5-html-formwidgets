# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   stop_tests => 1,
   license    => q(perl),
   module     => q(HTML::FormWidgets),
   home_page  => q(http://www.roxsoft.co.uk),
   requires   => {
      'perl'                    => q(5.008),
      'parent'                  => q(0.221),
      'version'                 => q(0.74),
      'Class::Accessor::Fast'   => q(0.31),
      'Class::MOP'              => q(0.84),
      'HTML::Accessors'         => q(0.4.0),
      'Pod::Xhtml'              => q(1.61),
      'Scalar::Util'            => q(1.23),
      'Syntax::Highlight::Perl' => q(1.00),
      'Text::ParseWords'        => q(3.22),
      'Text::Tabs'              => q(98.112801),
      'Try::Tiny'               => q(0.06), },
   configure_requires => { 'Module::Build' => 0.32,
                           'version'       => 0.74, },
   build_requires     => { 'Test::More'    => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# mode: perl
# tab-width: 3
# End:
