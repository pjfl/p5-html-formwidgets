# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.11.%d', q$Rev$ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use English qw( -no_match_vars );
use Module::Build;
use Test::More;

BEGIN {
   my $current = eval { Module::Build->current };

   $current and $current->notes->{stop_tests}
            and plan skip_all => $current->notes->{stop_tests};

   plan tests => 23;
}

use_ok q(HTML::FormWidgets);

my $widget = HTML::FormWidgets->new( id => q(test) );

ok( $widget->render =~ m{ input \s value="" \s name="test" \s type="text" }mx,
    'Default textfield' );

$widget = HTML::FormWidgets->new( href => q(test), type => q(anchor) );

ok( $widget->render =~ m{ a \s href="test" \s class="anchor_button \s fade" }mx,
    'Anchor' );

# Async

$widget = HTML::FormWidgets->new( id => q(test), type => q(button) );

ok $widget->render =~
  m{ input \s value="Test" \s name="_method" \s type="submit" \s id="test" }msx,
   'Button';

$widget = HTML::FormWidgets->new( id => q(test), type => q(checkbox) );

ok( $widget->render
       =~ m{ input \s value="1" \s name="test" \s type="checkbox" }mx,
    'Checkbox' );

# Chooser
# Cloud

$widget = HTML::FormWidgets->new( id => q(test), type => q(date) );

ok( $widget->render =~ m{ id="test_trigger" }mx, 'Date' );

$widget = HTML::FormWidgets->new( name => q(file),
                                  path => q(honestly),
                                  type => q(file) );

ok( $widget->render =~ m{ Path \s honestly \s not \s found }mx,
    'File not found' );

$widget->path( q(t/10base.t) );

ok( $widget->render =~ m{ use_ok \s q\(HTML::FormWidgets\) }mx,
    'File found' );

# Freelist
# GroupMembership

$widget = HTML::FormWidgets->new( default => q(test), type => q(hidden) );

ok $widget->render =~
   m{ input \s value="test" \s name="hidden" \s type="hidden" }msx,
   'Hidden';

$widget = HTML::FormWidgets->new( fhelp => q(Help Text),
                                  text  => q(http://localhost),
                                  type  => q(image) );

ok $widget->render =~
   m{ img \s alt="Help \s Text" \s src="http://localhost" }msx,
   'Image';

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(label) );

ok( $widget->render =~ m{ Test \s text }mx, 'Label' );

# Menu

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(note) );

ok( $widget->render =~ m{ >Test \s text</span> }mx, 'Note' );

# POD
# Paragraphs

$widget = HTML::FormWidgets->new( id      => q(test1),
                                  subtype => q(verify),
                                  type    => q(password) );

ok( $widget->render =~ m{ name="test2" \s type="password" }mx, 'Password' );

$widget = HTML::FormWidgets->new( id      => q(test),
                                  labels  => { 1 => q(One), 2 => q(Two) },
                                  type    => q(popupMenu),
                                  values  => [ 1, 2 ] );

ok( $widget->render =~ m{ <option \s value="2">Two</option> }mx,
    'Popup menu' );

$widget = HTML::FormWidgets->new( columns => 3,
                                  id      => q(test),
                                  labels  => { 1 => q(One),   2 => q(Two),
                                               3 => q(Three), 4 => q(Four),
                                               5 => q(Five),  6 => q(Six) },
                                  type    => q(radioGroup),
                                  values  => [ 1, 2, 3, 4, 5, 6 ] );

ok( $widget->render =~ m{ value="6" \s name="test" \s type="radio" }mx,
    'Radio group' );

$widget = HTML::FormWidgets->new( class => q(test), type => q(rule) );

ok $widget->render =~
   m{ td \s class="rule_section"><hr \s class="test" }msx, 'Rule';

# ScrollPin

$widget = HTML::FormWidgets->new( id     => q(test),
                                  type   => q(scrollingList),
                                  values => [ 1, 2, 3, 4 ], );

ok $widget->render =~ m{ id="test" \s multiple="multiple" }msx,
   'Scrolling List';

# SidebarPanel

$widget = HTML::FormWidgets->new( id => q(test), type => q(slider) );

ok( $widget->render =~ m{ class="knob" }mx, 'Slider' );

# TabSwapper

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

ok( $widget->render =~ m{ tr \s class=".*" \s id="table.row0" }mx, 'Table' );

# Template

$widget = HTML::FormWidgets->new( default => q(test), type => q(textarea) );

ok $widget->render =~ m{ textarea \s name="textarea" \s class="ifield">test }mx,
   'Text area';

$widget = HTML::FormWidgets->new( default => q(test), type => q(textfield) );

ok( $widget->render =~ m{ input \s value="test" \s name="textfield" \s type="text" \s class="ifield" \s size="40" }mx, 'Textfield' );

# Tree

my $data = [ { content => { text => q(t1), type => q(label) } },
             { content => { text => q(t2), type => q(label) } } ];

$widget = HTML::FormWidgets->new( data => $data, ordered => 1,
                                  type => q(list) );

ok $widget->render =~ m{ ol \s class="plain"><li }msx,
   'Ordered List';

$widget = HTML::FormWidgets->new( data => $data, type => q(list) );

ok $widget->render =~ m{ ul \s class="plain"><li }msx,
   'Unordered List';

# Local Variables:
# mode: perl
# tab-width: 3
# End:
