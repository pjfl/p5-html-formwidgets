#!/usr/bin/perl

# @(#)$Id: 10base.t 9 2008-02-10 22:40:42Z pjf $

use strict;
use warnings;
use English    qw(-no_match_vars);
use FindBin    qw($Bin);
use lib        qq($Bin/../lib);
use Test::More tests => 11;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev: 9 $ =~ /\d+/gmx );

BEGIN { use_ok q(HTML::FormWidgets) }

my $widget = HTML::FormWidgets->new( id => q(test) );

ok( $widget->render =~ m{ input \s value="" \s name="test" \s type="text" }mx,
    q(Default textfield) );

$widget = HTML::FormWidgets->new( href => q(test), type => q(anchor) );

ok( $widget->render =~ m{ a \s href="test" \s class="linkFade" }mx,
    q(Anchor) );

$widget = HTML::FormWidgets->new( id => q(test), type => q(checkbox) );

ok( $widget->render
       =~ m{ input \s value="1" \s name="test" \s type="checkbox" }mx,
    q(Checkbox) );

$widget = HTML::FormWidgets->new( id => q(test), type => q(date) );

ok( $widget->render =~ m{ href="" \s class="tips" \s id="anchor_test" }mx,
    q(Date) );

$widget = HTML::FormWidgets->new( hide => [],
                                  name => q(file),
                                  path => q(honestly),
                                  type => q(file) );

ok( $widget->render =~ m{ Not \s found \s honestly }mx, q(File not found) );

$widget->path( q(t/10base.t) );

ok( $widget->render =~ m{ use_ok \s q\(HTML::FormWidgets\) }mx,
    q(File found) );

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(label) );

ok( $widget->render =~ m{ Test \s text }mx, q(Label) );

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(note) );

ok( $widget->render =~ m{ class="note">Test \s text</div> }mx, q(Note) );

$widget = HTML::FormWidgets->new( id      => q(test1),
                                  subtype => q(verify),
                                  type    => q(password) );

ok( $widget->render =~ m{ name="test2" \s type="password" }mx, q(Password) );

$widget = HTML::FormWidgets->new( id      => q(test),
                                  labels  => { 1 => q(One), 2 => q(Two) },
                                  type    => q(popupMenu),
                                  values  => [ 1, 2 ] );

ok( $widget->render =~ m{ <option \s value="2">Two</option> }mx,
    q(Popup menu) );

warn $widget->render;
