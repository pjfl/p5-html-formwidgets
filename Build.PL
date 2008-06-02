#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $requires = { 'perl'                    => q(5.8),
                 'version'                 => q(0.74),
                 'Class::Data::Accessor'   => q(0.04001),
                 'HTML::Accessors'         => q(0.1.22),
                 'Readonly'                => q(1.03),
                 'Syntax::Highlight::Perl' => q(1.00),
                 'Text::ParseWords'        => q(3.22),
                 'Text::Tabs'              => q(98.112801) };
my $build = Module::Build->new
   ( build_requires     => { 'version' => q(0.74) },
     create_makefile_pl => q(traditional),
     create_readme      => 1,
     create_packlist    => 0,
     dist_version_from  => q(lib/HTML/FormWidgets.pm),
     license            => q(perl),
     module_name        => q(HTML::FormWidgets),
     requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
