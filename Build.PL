# @(#)$Id$

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.15.%d', q$Rev$ =~ /\d+/gmx );

Bob->new( {
   module     => q(HTML::FormWidgets),
   home_page  => q(http://www.roxsoft.co.uk),
   requires   => {
      'perl'                    => 5.010,
      'parent'                  => 0.221,
      'version'                 => 0.74,
      'Class::Accessor::Fast'   => 0.31,
      'HTML::Accessors'         => q(0.7.0),
      'Moose'                   => 2.0402,
      'Pod::Xhtml'              => 1.61,
      'PPI'                     => 1.213,
      'PPI::HTML'               => 1.08,
      'Scalar::Util'            => 1.23,
      'Text::ParseWords'        => 3.22,
      'Text::Tabs'              => 98.112801,
      'Try::Tiny'               => 0.06, },
   configure_requires => { 'Module::Build' => 0.32,
                           'version'       => 0.74, },
   build_requires     => { 'Test::More'    => 0.74, },
} )->create_build_script; # Goal!

# Local Variables:
# tab-title: FormWidgets
# eval: (load-project-state "html-formwidgets")
# mode: perl
# tab-width: 3
# End:
