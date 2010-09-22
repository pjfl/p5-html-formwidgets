# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

use Module::Build;

Module::Build->new
   ( add_to_cleanup     => [ q(Debian_CPANTS.txt), q(HTML-FormWidgets-*),
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::More' => q(0.74) },
     configure_requires => { 'version'    => q(0.74) },
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/FormWidgets.pm),
     license            => q(perl),
     module_name        => q(HTML::FormWidgets),
     no_index           => { directory => [ q(t) ] },
     requires           => {
        'perl'                    => q(5.008),
        'parent'                  => q(0.221),
        'version'                 => q(0.74),
        'Class::Accessor::Fast'   => q(0.31),
        'Class::MOP'              => q(0.84),
        'HTML::Accessors'         => q(0.3.0),
        'Pod::Xhtml'              => q(1.61),
        'Syntax::Highlight::Perl' => q(1.00),
        'Text::ParseWords'        => q(3.22),
        'Text::Tabs'              => q(98.112801),
        'Try::Tiny'               => q(0.06), },
     sign               => 1, )->create_build_script;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
