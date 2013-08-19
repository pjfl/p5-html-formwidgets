# @(#)$Ident: 10base.t 2013-08-19 16:46 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.20.%d', q$Rev: 2 $ =~ /\d+/gmx );
use File::Spec::Functions   qw( catdir updir );
use FindBin                 qw( $Bin );
use lib                 catdir( $Bin, updir, 'lib' );

use Module::Build;
use Test::More;

my $notes = {}; my $perl_ver;

BEGIN {
   my $builder = eval { Module::Build->current };
      $builder and $notes = $builder->notes;
      $perl_ver = $notes->{min_perl_version} || 5.008;
}

use Test::Requires "${perl_ver}";

use_ok 'HTML::FormWidgets';

my $widget = HTML::FormWidgets->new( id => 'test' );
my $r      = $widget->render;

like $r, qr{ input }mx,       'Default textfield 1';
like $r, qr{ value="" }mx,    'Default textfield 2';
like $r, qr{ name="test" }mx, 'Default textfield 3';
like $r, qr{ type="text" }mx, 'Default textfield 4';

$widget = HTML::FormWidgets->new( href => q(test), type => q(anchor) );
$r      = $widget->render;

like $r, qr{ a  }mx,                            'Anchor 1';
like $r, qr{ href="test" }mx,                   'Anchor 2';
like $r, qr{ class="anchor_button \s fade" }mx, 'Anchor 3';

# TODO: Async - test missing

$widget = HTML::FormWidgets->new( id => q(test), type => q(button) );
$r      = $widget->render;

like $r, qr{ input  }msx,         'Button 1';
like $r, qr{ value="Test" }msx,   'Button 2';
like $r, qr{ name="_method" }msx, 'Button 3';
like $r, qr{ type="submit" }msx,  'Button 4';
like $r, qr{ id="test" }msx,      'Button 5';

$widget = HTML::FormWidgets->new( id => q(test), type => q(checkbox) );
$r      = $widget->render;

like $r, qr{ input }mx,           'Checkbox 1';
like $r, qr{ value="1" }mx,       'Checkbox 2';
like $r, qr{ name="test" }mx,     'Checkbox 3';
like $r, qr{ type="checkbox" }mx, 'Checkbox 4';

# TODO: Chooser - test missing

$widget = HTML::FormWidgets->new
   ( data    => [ {
      colour => '#ff0000', count => 1, size => 1, tag => q(Item1), }, {
      colour => '#0000ff', count => 2, size => 2, tag => q(Item2), }, ],
     type    => q(cloud) );
$r      = $widget->render;

like $r, qr{ <div \s class="cloud_header"> }msx,             'Cloud 1';
like $r, qr{ class="cloud_header \s fade \s live_grid" }msx, 'Cloud 2';
like $r, qr{ id="Item1" }msx,                                'Cloud 3';
like $r, qr{ class="cloud_panel" }msx,                       'Cloud 4';
like $r, qr{ id="Item2Disp" }msx,                            'Cloud 5';

$widget = HTML::FormWidgets->new( id => q(test), type => q(date) );
$r      = $widget->render;

like $r, qr{ id="test_trigger" }mx, 'Date';

$widget = HTML::FormWidgets->new( name => q(file),
                                  path => q(honestly),
                                  type => q(file) );
$r      = $widget->render;

like $r, qr{ Path \s honestly \s not \s found }mx, 'File not found';

$widget->path( q(t/10base.t) ); $r = $widget->render;

like $r, qr{ use_ok \s 'HTML::FormWidgets' }mx, 'File found';

$widget = HTML::FormWidgets->new( id => q(test), type => q(freelist) );
$r      = $widget->render;

like $r, qr{ <span \s class="freelist_ifields"> }msx, 'Freelist 1';
like $r, qr{ input }msx,                              'Freelist 2';
like $r, qr{ value="" }msx,                           'Freelist 3';
like $r, qr{ name="_test" }msx,                       'Freelist 4';
like $r, qr{ type="text" }msx,                        'Freelist 5';
like $r, qr{ class="\s ifield \s freelist" }msx,      'Freelist 6';
like $r, qr{ id="test" }msx,                          'Freelist 7';

# TODO: GroupMembership - test missing

$widget = HTML::FormWidgets->new( default => q(test), type => q(hidden) );
$r      = $widget->render;

like $r, qr{ input }msx,         'Hidden 1';
like $r, qr{ value="test" }msx,  'Hidden 2';
like $r, qr{ name="hidden" }msx, 'Hidden 3';
like $r, qr{ type="hidden" }msx, 'Hidden 4';

$widget = HTML::FormWidgets->new( fhelp => q(Help Text),
                                  text  => q(http://localhost),
                                  type  => q(image) );
$r      = $widget->render;

like $r, qr{ img  }msx,                   'Image 1';
like $r, qr{ alt="Help \s Text" }msx,     'Image 2';
like $r, qr{ src="http://localhost" }msx, 'Image 3';

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(label) );
$r      = $widget->render;

like $r, qr{ Test \s text }mx, 'Label';

my $data = [ { content => { text => q(t1), type => q(label) } },
             { content => { text => q(t2), type => q(label) } } ];

$widget = HTML::FormWidgets->new( data => $data, ordered => 1,
                                  type => q(list) );
$r      = $widget->render;

like $r, qr{ ol }msx,            'List - ordered 1';
like $r, qr{ class="plain" }msx, 'List - ordered 2';
like $r, qr{ <li }msx,           'List - ordered 3';

$widget = HTML::FormWidgets->new( data => $data, type => q(list) );
$r      = $widget->render;

like $r, qr{ ul }msx,            'List - unordered 1';
like $r, qr{ class="plain" }msx, 'List - unordered 2';
like $r, qr{ <li }msx,           'List - unordered 3';

# TODO: Menu - test missing

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(note) );
$r      = $widget->render;

like $r, qr{ >Test \s text</span> }mx, 'Note';

# TODO: POD - test missing
# TODO: Paragraphs - test missing

$widget = HTML::FormWidgets->new( id      => q(test1),
                                  subtype => q(verify),
                                  type    => q(password) );
$r      = $widget->render;

like $r, qr{ name="test2" }mx,    'Password 1';
like $r, qr{ type="password" }mx, 'Password 2';

$widget = HTML::FormWidgets->new( id      => q(test),
                                  labels  => { 1 => q(One), 2 => q(Two) },
                                  type    => q(popupMenu),
                                  values  => [ 1, 2 ] );
$r      = $widget->render;

like $r, qr{ <option \s value="2">Two</option> }mx, 'Popup menu';

$widget = HTML::FormWidgets->new( columns => 3,
                                  id      => q(test),
                                  labels  => { 1 => q(One),   2 => q(Two),
                                               3 => q(Three), 4 => q(Four),
                                               5 => q(Five),  6 => q(Six) },
                                  type    => q(radioGroup),
                                  values  => [ 1, 2, 3, 4, 5, 6 ] );
$r      = $widget->render;

like $r, qr{ value="6" }mx,    'Radio group 1';
like $r, qr{ name="test" }mx,  'Radio group 2';
like $r, qr{ type="radio" }mx, 'Radio group 3';

$widget = HTML::FormWidgets->new( class => q(test), type => q(rule) );
$r      = $widget->render;

like $r, qr{ td \s class="most \s rule_section"><hr }msx, 'Rule 1';
like $r, qr{ class="test" }msx,                           'Rule 2';

# TODO: ScrollPin - test missing

$widget = HTML::FormWidgets->new( id     => q(test),
                                  type   => q(scrollingList),
                                  values => [ 1, 2, 3, 4 ], );
$r      = $widget->render;

like $r, qr{ id="test" }msx,           'Scrolling List 1';
like $r, qr{ multiple="multiple" }msx, 'Scrolling List 2';

# TODO: SidebarPanel - test missing

$widget = HTML::FormWidgets->new( id => q(test), type => q(slider) );
$r      = $widget->render;

like $r, qr{ class="knob" }mx, 'Slider';

# TODO: TabSwapper - test missing

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
$r      = $widget->render;

like $r, qr{ tr }mx,              'Table 1';
like $r, qr{ class=".*" }mx,      'Table 2';
like $r, qr{ id="table.row0" }mx, 'Table 3';

# TODO: Template - test missing

$widget = HTML::FormWidgets->new( default => q(test), type => q(textarea) );
$r      = $widget->render;

like $r, qr{ name="textarea" }mx, 'Textarea 1';
like $r, qr{ class="ifield" }mx,  'Textarea 2';
like $r, qr{ rows="1" }mx,        'Textarea 3';
like $r, qr{ cols="60" }mx,       'Textarea 4';
like $r, qr{ >test }mx,           'Textarea 5';

$widget = HTML::FormWidgets->new( default => q(test), type => q(textfield) );
$r      = $widget->render;

like $r, qr{ value="test" }mx,     'Textfield 1';
like $r, qr{ name="textfield" }mx, 'Textfield 2';
like $r, qr{ type="text" }mx,      'Textfield 3';
like $r, qr{ class="ifield" }mx,   'Textfield 4';
like $r, qr{ size="40" }mx,        'Textfield 5';

# TODO: Tree - test missing

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
