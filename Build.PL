# @(#)$Ident: Build.PL 2013-05-16 14:18 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.19.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(HTML::FormWidgets),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'            => 5.01,
      'parent'          => 0.224,
      'Class::Accessor' => 0.34,
      'HTML::Accessors' => q(0.7.0),
      'Moose'           => 2.0402,
      'Pod::Xhtml'      => 1.61,
      'PPI'             => 1.215,
      'PPI::HTML'       => 1.08,
      'Try::Tiny'       => 0.09, },
   recommends           => {
      'App::cpanminus'  => 1.6005, },
   configure_requires   => {
      'version'         => 0.88,
      'Module::Build'   => 0.4004, },
   build_requires       => {
      'version'         => 0.88,
      'Module::Build'   => 0.4004, },
} )->create_build_script; # Goal!

# Local Variables:
# tab-title: FormWidgets
# eval: (load-project-state "html-formwidgets")
# mode: perl
# tab-width: 3
# End:
