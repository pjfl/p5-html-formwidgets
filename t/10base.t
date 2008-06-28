#!/usr/bin/perl

# @(#)$Id: 10base.t 9 2008-02-10 22:40:42Z pjf $

use strict;
use warnings;
use English    qw(-no_match_vars);
use FindBin    qw($Bin);
use lib        qq($Bin/../lib);
use Test::More tests => 15;

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

ok( $widget->render =~ m{ href="" \s class="tips" \s id="test_anchor" }mx,
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

$widget = HTML::FormWidgets->new( columns => 3,
                                  id      => q(test),
                                  labels  => { 1 => q(One),   2 => q(Two),
                                               3 => q(Three), 4 => q(Four),
                                               5 => q(Five),  6 => q(Six) },
                                  type    => q(radioGroup),
                                  values  => [ 1, 2, 3, 4, 5, 6 ] );

ok( $widget->render =~ m{ value="6" \s name="test" \s type="radio" }mx,
    q(Radio group) );

$widget = HTML::FormWidgets->new( data   => {
   flds   => [ qw(Field1 Field2) ],
   labels => { Field1 => q(Label1),
               Field2 => q(Label2) },
   sizes  => { Field1 => 20, Field2 => 20 },
   values => [ { Field1 => q(Row1 Value1),
                 Field2 => q(Row1 Value2) },
               { Field1 => q(Row2 Value1),
                 Field2 => q(Row2 Value2) } ] },
                                  hide   => [],
                                  name   => q(table),
                                  type   => q(table) );

ok( $widget->render =~ m{ tr \s id="table_row1" }mx, q(Table) );

$widget = HTML::FormWidgets->new( name => q(textarea),
                                  type => q(textarea) );

ok( $widget->render =~ m{ id="textarea" \s rows="5" \s cols="60" }mx,
    q(Text area) );

$widget = HTML::FormWidgets->new( default => q(test),
                                  name    => q(textfield),
                                  type    => q(textfield) );

ok( $widget->render =~ m{ input \s value="test" \s name="textfield" \s type="text" \s id="textfield" \s size="60" }mx, q(Textfield) );
