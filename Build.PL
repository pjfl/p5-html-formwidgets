# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

use Module::Build;

my $build = Module::Build->new
   ( add_to_cleanup     => [ 'Debian_CPANTS.txt', 'HTML-FormWidgets-*',
                             'Makefile', map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::More'          => q(0.74) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/FormWidgets.pm),
     license            => q(perl),
     module_name        => q(HTML::FormWidgets),
     notes              => { cpan_testers_version => 1 },
     requires           => { 'perl'                    => q(5.008),
                             'parent'                  => q(0.221),
                             'version'                 => q(0.74),
                             'Class::Accessor::Fast'   => q(0.31),
                             'Class::MOP'              => q(0.84),
                             'HTML::Accessors'         => q(0.1.22),
                             'Pod::Html'               => q(1.0504),
                             'Syntax::Highlight::Perl' => q(1.00),
                             'Text::Markdown'          => q(1.0.20),
                             'Text::ParseWords'        => q(3.22),
                             'Text::Tabs'              => q(98.112801),
                             'TryCatch'                => 1.002000, },
     sign               => 1, );

$build->create_build_script;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
