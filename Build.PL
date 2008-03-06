#!/usr/bin/perl

# @(#)$Id$

use strict;
use warnings;
use Module::Build;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

my $dist     = q(lib/HTML/FormWidgets.pm);
my $requires = { 'perl'                  => q(5.8),
                 'version'               => q(0.74),
                 'Class::Accessor::Fast' => q(0.31),
                 'HTML::Accessors'       => q(0.1.0),
                 'Readonly'              => q(1.03) };
my $build    = Module::Build->new( create_makefile_pl => q(traditional),
                                   create_readme      => 1,
                                   create_packlist    => 0,
                                   dist_version_from  => $dist,
                                   license            => q(perl),
                                   module_name        => q(HTML::FormWidgets),
                                   requires           => $requires );

$build->create_build_script();

# Local Variables:
# mode: perl
# tab-width: 3
# End:
