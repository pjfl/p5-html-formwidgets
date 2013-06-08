# Name

HTML::FormWidgets - Create HTML user interface components

# Version

Describes version v0.19.$Rev: 3 $ of [HTML::FormWidgets](https://metacpan.org/module/HTML::FormWidgets)

# Synopsis

    use HTML::FormWidgets;

    my $widget = HTML::FormWidgets->new( id => q(test) );

    print $widget->render;
    # <div class="container">
    # <input value="" name="test" type="text" id="test" class="ifield" size="40">
    # </div>

# Description

Transforms a Perl data structure which defines one or more "widgets"
into HTML or XHTML. Each widget is comprised of these optional
components: a line or question number, a prompt string, a separator,
an input field, additional field help, and Ajax field error string.

Input fields are selected by the widget `type` attribute. A factory
subclass implements the method that generates the HTML or XHTML for
that input field type. Adding more widget types is straightforward

This module is using the [MooTools](http://mootools.net/) Javascript
library to modify default browser behaviour

This module is used by [CatalystX::Usul::View](https://metacpan.org/module/CatalystX::Usul::View) and as such its
main use is as a form generator within a [Catalyst](https://metacpan.org/module/Catalyst) application

# Configuration and Environment

The following are passed to ["build"](#build) in the `config` hash (they
reflect this modules primary use within a [Catalyst](https://metacpan.org/module/Catalyst) application):

- `assets`

    Some of the widgets require image files. This attribute is used to
    create the URI for those images

- `base`

    This is the prefix for our URI

- `content_type`

    Either `application/xhtml+xml` which generates XHTML 1.1 or
    `text/html` which generates HTML 4.01 and is the default

- `fields`

    This hash ref contains the fields definitions. Static parameters for
    each widget can be stored in configuration files. This reduces the
    number of attributes that have to be passed in the call to the
    constructor

- `hidden`

    So that the ["File"](#File) and ["Table"](#Table) subclasses can store the number
    of rows added as the hidden form attribute `nRows`

- `js_object`

    This is the name of the global Javascript variable that holds
    `config` object. Defaults to `html_formwidgets`

- `root`

    The path to the document root for this application

- `width`

    Width in pixels of the browser window. This is used to calculate the
    width of the field prompt. The field prompt needs to be a fixed length
    so that the separator colons align vertically

- `templatedir`

    The path to template files used by the ["Template"](#Template) subclass

Sensible defaults are provided by `new` if any of the above are undefined

# Subroutines/Methods

## Public Methods

### build

      HTML::FormWidgets->build( $config_hash );

The ["build"](#build) method iterates over a data structure that represents the
form. One or more lists of widget definitions are processed in
turn. New widgets are created and their rendered output replaces their
definitions in the data structure

### new

    $widget = HTML::FormWidgets->new( [{] key1 => value1, ... [}] );

Construct a widget. Mostly this is called by the ["build"](#build) method. It
requires the factory subclass for the widget type.

This method takes a large number of options with each widget using
only few of them. Each option is described in the factory subclasses
which use that option

### add\_hidden

    $widget->add_hidden( $key, $value );

The key / value pair are added to list of hidden input elements that will
be included in the page

### add\_literal\_js

    $widet->add_literal_js( $js_class_name, $id, $config );

The config hash will be serialised and added to the literal Javascript on
the page

### add\_optional\_js

    $widget->add_optional_js( @filenames );

The list of Javascript filenames (with extension, without path) are added
to the list of files which will be included on the page

### inflate

    $widget->inflate( $args );

Creates [new](https://metacpan.org/module/HTML::FormWidgets#new) objects and returns their rendered output.
Called by the ["\_render"](#\_render) methods in the factory subclasses to inflate
embeded widget definitions

### init

    $widget->init( $args );

Initialises this object with data from the passed arguments. This is
usually overridden in the factory subclass which sets the default for
it's own attributes. In the base class this method does nothing

### is\_xml

    $bool = $widget->is_xml;

Returns true if the content type matches `xml`

### loc

    $message_text = $widget->loc( $message_id, @args );

Use the supplied key to return a value from the `l10n` object. This
object was passed to the constructor and should localize the key to
the required language. The `@args` list contains parameters to substituted
in place of the placeholders which have the form `[_n]`

### render

    $html = $widget->render;

Assemble the components of the generated widget. Each component is
concatenated onto a scalar which is the returned value. This method
calls ["render\_field"](#render\_field) which should be defined in the factory subclass for
this widget type.

This method uses these attributes:

- `clear`

    If set to `left` the widget begins with an `<br>` element

- `stepno`

    If true it's value is wrapped in a `<span class="lineNumber">`
    element and appended to the return value

- `prompt`

    If true it's value is wrapped in a `<label class="prompt_class">`
    element and appended to the return value. The prompt class is set by
    the `pclass` attribute. The `id` attribute is used to set the `for`
    attribute of the `<label>` element.  The `pwidth` attribute sets
    the width style attribute in the `<label>` element

- `sep`

    If true it's value is wrapped in a `<span class="separator">`
    element and appended to the return value

- `container`

    If true the value return by the ["\_render"](#\_render) method is wrapped in
    `<span class="container">` element

- `tip`

    The text of the field help. If `tiptype` is set to `dagger`
    (which is the default) then a dagger symbol is
    wrapped in a `<span class="help tips">` and this is appended to the
    returned input field. The tip text is used as the `title`
    attribute. If the `tiptype` is not set to `dagger` then the help
    text is wrapped around the input field itself

- `check_field`

    Boolean which if true causes the field to generate server side check field
    requests

### render\_check\_field

Adds markup for the Ajax field validation

### render\_container

Wraps the rendered field in a containing div

### render\_field

Should be overridden in the factory subclass. It should return the markup
for the specified field type

### render\_prompt

Adds a label element to the generated markup

### render\_separator

Insert a spacing element between the prompt and the field

### render\_stepno

Markup containing the step number on the form if required

### render\_tip

Flyover tooltip field help text

## Private Methods

### \_bootstrap

    $widget->_bootstrap( $args );

Determine the `id`, `name` and `type` attributes of the widget from
the supplied arguments

### \_ensure\_class\_loaded

    $widget->_ensure_class_loaded( $class );

Once the factory subclass is known this method ensures that it is loaded
and then re-blesses the self referential object into the correct class

### \_set\_error

    $widget->_set_error( $error_text );

Stores the passed error message in the `text` attribute so that it
gets rendered in place of the widget

## Private Subroutines

### \_\_arg\_list

    $args = __arg_list( @args );

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

### \_\_form\_wrapper

    $item = __form_wrapper( $options, $item, $stack );

Wraps the top `nitems` number of widgets on the build stack in a `<form>` element

### \_\_group\_fields

    $item = __group_fields( $options, $item, $stack );

Wraps the top `nitems` number of widgets on the build stack in a `<fieldset>` element with a legend

# Factory Subclasses

These are the possible values for the `type` attribute which defaults
to `textfield`. Each subclass implements the ["\_render"](#\_render) method, it
receives a hash ref of options an returns a scalar containing some
XHTML.

The distribution ships with the following factory subclasses:

## Anchor

Returns an `<anchor>` element with a class set from the `class`
argument (which defaults to `linkFade`). It's `href` attribute
set to the `href` argument. The anchor body is set to the `text`
argument

## Async

Returns a `<div>` element with a class set from the `class`
argument (which defaults to `server`). The div body is set to the
`text` argument. When the JavaScript `onload` event handler fires it
will asynchronously load the content of the div if it is visible

## Button

Generates an image button where `name` identifies the image
file in `assets` and is also used as the return value. The
button name is set to `_verb`. If the image file does not
exist a regular input button is rendered instead

## Checkbox

Return a `<checkbox>` element of value `value`. Use the
element's value as key to the `labels` hash. The hash value
(which defaults null) is used as the displayed label. The
`checked` argument determines the checkbox's initial
setting

## Chooser

Creates a popup window which allows one item to be selected from a
long list of items

## Cloud

Creates list of links from the data set supplied in the `data` argument

## Date

Return another `<textfield>`, this time with a calendar icon
which when clicked pops up a Javascript date picker. Requires the
appropriate JavaScript library to have been loaded by the page. Attribute
`width` controls the size of the `<textfield>` (default 10
characters) and `format` defaults to `dd/mm/yyyy`. Setting the
`readonly` attribute to true (which is the default) causes the input
`<textfield>` to become read only

## File

Display the contents of a file pointed to by `path`. Supports the
following subtypes:

- `csv`

    Return a table containing the CSV formatted file. This and the `file`
    subtype are selectable if `select` >= 0 and represents the
    column number of the key field

- `file`

    Default subtype. Like the logfile subtype but without the `<pre>` tags

- `html`

    The ["\_render"](#\_render) method returns an `<iframe>` element whose `src`
    attribute is set to `path`. Paths that begin with `root` will have
    that replaced with the `base` attribute value. Paths that do not
    begin with `http:` will have the `base` attribute value prepended to
    them

- `logfile`

    The ["\_render"](#\_render) method returns a table where each line of the logfile
    appears as a separate row containing one cell. The logfile lines are
    each wrapped in `<pre>` tags

- `source`

    The module [Syntax::Highlight::Perl](https://metacpan.org/module/Syntax::Highlight::Perl) is used to provide colour
    highlights for the Perl source code. Tabs are expanded to
    `tabstop` spaces and the result is returned wrapped in
    `<pre>` tags

## Freelist

New values entered into a text field can be added to the
list. Existing list values (passed in `values`) can be
removed. The height of the list is set by `height`.

## GroupMembership

Displays two lists which allow for membership of a group. The first
scrolling list contains "all" values (`all`), the second
contains those values currently selected (`current`). The
height of the scrolling lists is set by `height`

## Hidden

Generates a hidden input field. Uses the `default` attribute as the value

## Image

Generates an image tag. The `text` attribute contains the source URI. The
`fhelp` attribute contains the alt text and the `tiptype` attribute is
defaulted to `normal` (wraps the image in a span with a JavaScript tooltip)

## Label

Calls ["loc"](#loc) with the `text` attribute if set otherwise returns nothing.
If `dropcap` is true the first character of the text is wrapped
in a `<span class="dropcap">`. Wraps the text in a span of class
`class` which defaults to `label_text`

## List

Generates an ordered and unordered lists of items. Set the `ordered`
attribute to true for an ordered list. Defaults to false

## Menu

Generates an unordered list of links. Used with some applied CSS to
implement a navigation menu

## Note

Calls ["localize"](#localize) with the `name` attribute as the message key. If
the message does not exist the value if the `text` attribute is
used. The text is wrapped in a c<< <span class="note"> >> with
`width` setting the style width

## POD

Uses [Pod::Html](https://metacpan.org/module/Pod::Html) to render the POD in the given module as HTML

## Paragraphs

Newspaper like paragraphs rendered in a given number of columns, each
approximately the same length. Defines these attributes;

- `column_class`

    CSS class name of the `<span>` wrapped around each column. Defaults
    to null

- `columns`

    Number of columns to render the paragraphs in. Defaults to 1

- `data`

    Paragraphs of text. A hash ref whose `values` attribute is an array
    ref. The values of that array are the hash refs that define each
    paragraph. The keys of the paragraph hash ref are `class`, `heading`, and
    `text`.

- `hclass`

    Each paragraph can have a heading. This is the class of the `<div>` that wraps the heading text. Defaults to null

- `max_width`

    Maximum width of all paragraphs expressed as a percentage. Defaults
    to 90

- `para_lead`

    Paragraph leading. This value is in characters. It is added to the size of
    each paragraph to account for the leading applied by the CSS to each
    paragraph. If a paragraph is split, then the first part must by greater
    than twice this value or the widows and orphans trap will reap it

## Password

Returns a password field of width `width` which defaults to
twenty characters. If `subtype` equals `verify` then the
message `vPasswordPrompt` and another password field are
appended. The fields `id` and `name` are expected
to contain the digit 1 which will be substituted for the digit 2 in
the attributes of the second field

## PopupMenu

Returns a list of `<option>` elements wrapped in a `<select>`
element. The list of options is passed in `values` with the
display labels in `labels`. The `onchange` event handler will
be set to the `onchange` attribute value

## RadioGroup

The attribute `columns` sets the number of columns for the
returned table of radio buttons. The list of button values is passed in
`values` with the display labels in `labels`. The
`onchange` event handler will be set to `onchange`

## Rule

Generates a horizontal rule with optional clickable action

## ScrollPin

Implements clickable navigation markers that scroll the page to given
location. Returns an unordered list of class `class` which defaults
to `pintray`. This is the default selector class for the JavaScript
`ScrollPins` object

## ScrollingList

The `height` attribute controls the number of options the scrolling
list displays.  The list of options is passed in `values` with the
display labels in `labels`. The `onchange` event handler will
be set to `onchange`

## SidebarPanel

Generates the markup for a sidebar accordion panel (a "header" `div`
and a "body" `div`). The panel contents are requested asynchronously
by the browser. The ["SidebarPanel"](#SidebarPanel) widget defines these attributes:

- `config`

    A hash ref whose keys and values are written out as literal JavaScript by
    ["add\_literal\_js"](#add\_literal\_js)

- `header`

    A hash that provides the `id`, `class`, and `text` for header `div`

- `panel`

    A hash that provides the `id` and `class` for body `div`

## Slider

Implements a dragable slider which returns an integer value. The ["Slider"](#Slider)
widget defines these attributes:

- `display`

    Boolean which if true causes the widget to display a read only text
    field containing the sliders current value. If false a ` <hidden` >>
    element is generated instead. Defaults to `1`

- `element`

    Name of the Javascript instance variable. This will need setting to a
    unique value for each slider on the same form. Defaults to
    `behaviour.sliderElement`

- `hide`

    If the `display` attribute is false the current value is pushed onto
    this array. Defaults to `[]`

- `mode`

    Which orientation to render in. Defaults to `horizontal`

- `offset`

    Sets the minimum value for the slider. Defaults to `0`

- `range`

    The range is either the offset plus the number of steps or the two
    values of this array if it is set. Defaults to `false`

- `snap`

    Snap to the nearest step value? Defaults to `1`

- `steps`

    Sets the number of steps. Defaults to `100`

- `wheel`

    Use the mouse wheel? Defaults to `1`

## TabSwapper

A list of `div`s is constructed that can be styled to display only one at
a time. Clicking the tab header displays the corresponding `div`

## Table

The input data is in `$data->{values}` which is an array
ref for which each element is an array ref containing the list of
field values.

## TableRow

Returns markup for a table row. Used to generate responses for the `LiveGrid`
JavaScript class

## Template

Look in `templatedir` for a [Template::Toolkit](https://metacpan.org/module/Template::Toolkit) template
called `id` with a `.tt` extension. Slurp it in and return
it as the content for this widget. This provides for a "user defined"
widget type

## Textarea

A text area. It defaults to five lines high (`height`) and
sixty characters wide (`width`)

## Textfield

This is the default widget type. Your basic text field which defaults
to sixty characters wide (`width`)

## Tree

Implements an expanding tree of selectable objects

# Diagnostics

None

# Dependencies

- [Class::Accessor::Fast](https://metacpan.org/module/Class::Accessor::Fast)
- [Class::Load](https://metacpan.org/module/Class::Load)
- [HTML::Accessors](https://metacpan.org/module/HTML::Accessors)
- [Syntax::Highlight::Perl](https://metacpan.org/module/Syntax::Highlight::Perl)
- [Text::ParseWords](https://metacpan.org/module/Text::ParseWords)
- [Text::Tabs](https://metacpan.org/module/Text::Tabs)
- [Try::Tiny](https://metacpan.org/module/Try::Tiny)

Included in the distribution are the Javascript files whose methods
are called by the event handlers associated with these widgets

## `05htmlparser.js`

    HTML Parser By John Resig (ejohn.org)
    Original code by Erik Arvidsson, Mozilla Public License
    http://erik.eae.net/simplehtmlparser/simplehtmlparser.js

Used to reimplement `innerHTML` assignments from XHTML

## `10mootools.js`

    Mootools - My Object Oriented javascript.
    License: MIT-style license.
    WWW: http://mootools.net/

This is the main JavaScript library used with this package

## `15html-formwidgets.js`

Replaces Mootools' `setHTML` method with one that uses the HTML
parser. The included copy has a few hacks that improve the Accordion
widget

## `50calendar.js`

    Copyright Mihai Bazon, 2002-2005  |  www.bazon.net/mishoo
    The DHTML Calendar, version 1.0   |  www.dynarch.com/projects/calendar
    License: GNU Lesser General Public License

Implements the calendar popup used by the `::Date` subclass

## `behaviour.js`

Is included from the [App::Munchies](https://metacpan.org/module/App::Munchies) default skin. It uses the
MooTools library to implement the server side field validation

Also included in the `images` subdirectory of the distribution are
example PNG files used by some of the widgets.

# Incompatibilities

There are no known incompatibilities in this module.

# Bugs and Limitations

The installation script does nothing with the Javascript or PNG files
which are included in the distribution for completeness

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2012 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
