# @(#)$Id$

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.17.%d', q$Rev$ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use Module::Build;
use Test::More;

BEGIN {
   my $current = eval { Module::Build->current };

   $current and $current->notes->{stop_tests}
            and plan skip_all => $current->notes->{stop_tests};
}

use HTML::FormWidgets;

my $widget = HTML::FormWidgets->new( id => q(test) );

like $widget->render, qr{ input \s value="" \s name="test" \s type="text" }mx,
    'Default textfield';

$widget = HTML::FormWidgets->new( href => q(test), type => q(anchor) );

like $widget->render, qr{ a \s href="test" \s class="anchor_button \s fade" }mx,
    'Anchor';

# TODO: Async - test missing

$widget = HTML::FormWidgets->new( id => q(test), type => q(button) );

like $widget->render,
   qr{ input \s value="Test" \s name="_method" \s type="submit" \s
          id="test" }msx, 'Button';

$widget = HTML::FormWidgets->new( id => q(test), type => q(checkbox) );

like $widget->render,
   qr{ input \s value="1" \s name="test" \s type="checkbox" }mx, 'Checkbox';

# TODO: Chooser - test missing

$widget = HTML::FormWidgets->new
   ( data    => [ {
      colour => '#ff0000', count => 1, size => 1, tag => q(Item1), }, {
      colour => '#0000ff', count => 2, size => 2, tag => q(Item2), }, ],
     type    => q(cloud) );

like $widget->render,
   qr{ <div \s class="cloud_header"> .*
          class="cloud_header \s fade \s live_grid" \s id="Item1" .*
          class="cloud_panel" \s id="Item2Disp" }msx, 'Cloud';

$widget = HTML::FormWidgets->new( id => q(test), type => q(date) );

like $widget->render, qr{ id="test_trigger" }mx, 'Date';

$widget = HTML::FormWidgets->new( name => q(file),
                                  path => q(honestly),
                                  type => q(file) );

like $widget->render, qr{ Path \s honestly \s not \s found }mx,
   'File not found';

$widget->path( q(t/10base.t) );

like $widget->render, qr{ use \s HTML::FormWidgets }mx, 'File found';

$widget = HTML::FormWidgets->new( id => q(test), type => q(freelist) );

like $widget->render,
   qr{ <span \s class="freelist_ifields"><input \s
          value="" \s name="_test" \s type="text" \s
          class="\s ifield \s freelist" \s id="test" }msx, 'Freelist';

# TODO: GroupMembership - test missing

$widget = HTML::FormWidgets->new( default => q(test), type => q(hidden) );

like $widget->render,
   qr{ input \s value="test" \s name="hidden" \s type="hidden" }msx, 'Hidden';

$widget = HTML::FormWidgets->new( fhelp => q(Help Text),
                                  text  => q(http://localhost),
                                  type  => q(image) );

like $widget->render,
   qr{ img \s alt="Help \s Text" \s src="http://localhost" }msx, 'Image';

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(label) );

like $widget->render, qr{ Test \s text }mx, 'Label';

my $data = [ { content => { text => q(t1), type => q(label) } },
             { content => { text => q(t2), type => q(label) } } ];

$widget = HTML::FormWidgets->new( data => $data, ordered => 1,
                                  type => q(list) );

like $widget->render, qr{ ol \s class="plain"><li }msx, 'List - ordered ';

$widget = HTML::FormWidgets->new( data => $data, type => q(list) );

like $widget->render, qr{ ul \s class="plain"><li }msx, 'List - unordered ';

# TODO: Menu - test missing

$widget = HTML::FormWidgets->new( id   => q(test),
                                  text => q(Test text),
                                  type => q(note) );

like $widget->render, qr{ >Test \s text</span> }mx, 'Note';

# TODO: POD - test missing
# TODO: Paragraphs - test missing

$widget = HTML::FormWidgets->new( id      => q(test1),
                                  subtype => q(verify),
                                  type    => q(password) );

like $widget->render, qr{ name="test2" \s type="password" }mx, 'Password';

$widget = HTML::FormWidgets->new( id      => q(test),
                                  labels  => { 1 => q(One), 2 => q(Two) },
                                  type    => q(popupMenu),
                                  values  => [ 1, 2 ] );

like $widget->render, qr{ <option \s value="2">Two</option> }mx, 'Popup menu';

$widget = HTML::FormWidgets->new( columns => 3,
                                  id      => q(test),
                                  labels  => { 1 => q(One),   2 => q(Two),
                                               3 => q(Three), 4 => q(Four),
                                               5 => q(Five),  6 => q(Six) },
                                  type    => q(radioGroup),
                                  values  => [ 1, 2, 3, 4, 5, 6 ] );

like $widget->render, qr{ value="6" \s name="test" \s type="radio" }mx,
    'Radio group';

$widget = HTML::FormWidgets->new( class => q(test), type => q(rule) );

like $widget->render,
   qr{ td \s class="most \s rule_section"><hr \s class="test" }msx, 'Rule';

# TODO: ScrollPin - test missing

$widget = HTML::FormWidgets->new( id     => q(test),
                                  type   => q(scrollingList),
                                  values => [ 1, 2, 3, 4 ], );

like $widget->render, qr{ id="test" \s multiple="multiple" }msx,
   'Scrolling List';

# TODO: SidebarPanel - test missing

$widget = HTML::FormWidgets->new( id => q(test), type => q(slider) );

like $widget->render, qr{ class="knob" }mx, 'Slider';

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

like $widget->render, qr{ tr \s class=".*" \s id="table.row0" }mx, 'Table';

# TODO: Template - test missing

$widget = HTML::FormWidgets->new( default => q(test), type => q(textarea) );

like $widget->render,
   qr{ textarea \s name="textarea" \s class="ifield" \s rows="1" \s cols="60">test }mx, 'Textarea';

$widget = HTML::FormWidgets->new( default => q(test), type => q(textfield) );

like $widget->render,
   qr{ input \s value="test" \s name="textfield" \s type="text" \s
          class="ifield" \s size="40" }mx, 'Textfield';

# TODO: Tree - test missing

done_testing;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
