#!/usr/bin/perl

# @(#)$Id: 10base.t 9 2008-02-10 22:40:42Z pjf $

use strict;
use warnings;
use English qw(-no_match_vars);
use FindBin qw($Bin);
use lib qq($Bin/../lib);
use Test::More tests => 1;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 9 $ =~ /\d+/gmx );

BEGIN { use_ok q(HTML::FormWidgets) }

my $widget  = HTML::FormWidgets->new();
