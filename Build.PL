#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.4.%d', q$Rev$ =~ /\d+/gmx );

my $requires = { 'perl'                    => q(5.008),
                 'parent'                  => q(0.221),
                 'version'                 => q(0.74),
                 'Class::Accessor::Fast'   => q(0.31),
                 'Class::Inspector'        => q(1.18),
                 'HTML::Accessors'         => q(0.1.22),
                 'Syntax::Highlight::Perl' => q(1.00),
                 'Text::Markdown'          => q(1.0.20),
                 'Text::ParseWords'        => q(3.22),
                 'Text::Tabs'              => q(98.112801) };
my $build = Module::Build->new
   ( add_to_cleanup     => [ 'HTML-FormWidgets-*',
                             map { ( '*/' x $_ ) . '*~' } 0..5 ],
     build_requires     => { 'Test::Harness'       => q(2.64),
                             'Test::More'          => q(0.74),
                             'Test::Pod'           => q(1.14) },
     configure_requires => { 'ExtUtils::MakeMaker' => q(6.42),
                             'version'             => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/FormWidgets.pm),
     license            => q(perl),
     module_name        => q(HTML::FormWidgets),
     notes              => { cpan_testers_version => 1 },
     requires           => $requires,
     sign               => 1 );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
