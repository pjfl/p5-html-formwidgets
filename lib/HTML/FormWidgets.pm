package HTML::FormWidgets;

# @(#)$Id$

use strict;
use warnings;
use base    qw(Class::Data::Accessor);
use English qw(-no_match_vars);
use File::Spec::Functions;
use HTML::Accessors;
use Readonly;
use Text::Markdown qw(markdown);

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $NUL   => q();
Readonly my $TTS   => q( ~ );
Readonly my %ATTRS =>
   ( ajaxid       => undef,         ajaxtext     => undef,
     align        => q(left),       all          => [],
     alt          => undef,
     assets       => $NUL,          atitle       => 'All',
     base         => $NUL,          behaviour    => q(classic),
     button       => $NUL,          checked      => 0,
     class        => $NUL,          clear        => $NUL,
     columns      => undef,         container    => undef,
     content_type => q(application/xhtml+xml),
     ctitle       => 'Current',     current      => [],
     data         => {},            default      => undef,
     dropcap      => 0,             edit         => 0,
     elem         => undef,         evnt_hndlr   => 'serverObj.checkField',
     field        => $NUL,          fields       => {},
     form         => {},            'format'     => undef,
     fhelp        => $NUL,          header       => undef,
     height       => undef,         hide         => [],
     hint_title   => 'Handy Hint',  href         => undef,
     id           => undef,         id2key       => {},
     imgclass     => undef,
     key          => $NUL,          key2id       => {},
     key2url      => {},            labels       => undef,
     max_length   => undef,         messages     => undef,
     name         => $NUL,          nb_symbol    => q(&nbsp;&dagger;),
     node         => undef,         nowrap       => 0,
     onblur       => undef,         onchange     => undef,
     onclick      => undef,         onkeypress   => undef,
     palign       => undef,         path         => undef,
     prompt       => $NUL,          fields       => {},
     pwidth       => 40,            required     => 0,
     root         => undef,         select       => undef,
     sep          => q(&nbsp;:&nbsp;),
     space        => q(&nbsp;) x 3, stepno       => undef,
     style        => $NUL,          subtype      => undef,
     swidth       => 1000,          tabstop      => 3,
     target       => $NUL,          templatedir  => undef,
     text         => $NUL,
     text_obj     => undef,         tip          => $NUL,
     tiptype      => q(dagger),     title        => $NUL,
     type         => undef,         url          => undef,
     value        => 1,             values       => [],
     width        => undef, );

Readonly my @STATIC => (
   qw(atitle align behaviour checked class clear container ctitle edit
      fhelp format height hint_title max_length max_value min_length
      min_value nowrap onchange onkeypress palign prompt pwidth
      required select sep stepno subtype tabstop text tip tiptype
      width) );

__PACKAGE__->mk_classaccessors( keys %ATTRS );

# Class methods

sub build {
   my ($me, $config, $form) = @_; my ($item, $list, $ref, @tmp, $widget);

   for $list (@{ $form }) {
      next unless ($list && ref $list eq q(HASH));

      @tmp = ();

      for $item (@{ $list->{items} }) {
         if (ref $item->{content} eq q(HASH)) {
            if ($item->{content}->{group}) {
               $ref = { content => $me->_group_fields( $item, \@tmp ) };
            }
            elsif ($item->{content}->{widget}) {
               $widget = $me->new( $me->_merge_config( $config, $item ) );
               $ref    = { content => $widget->render };
               $ref->{class} = $widget->class if ($widget->class);
            }
            else { $ref = $item->{content} }
         }
         else { $ref = { content => $item->{content} } }

         $ref->{rownum} = $item->{rownum} if (defined $item->{rownum});
         push @tmp, $ref;
      }

      @{ $list->{items} } = @tmp;
   }

   return;
}

sub new {
   my ($me, @rest) = @_;
   my $args        = $me->_arg_list( @rest );
   my ($class, $method, $msg_id, $ref, $self, $suffix, $text, @tmp, $val);

   # Start with some hard coded defaults;
   $self = { %ATTRS };

   # Now we can create HTML elements like we could with CGI.pm
   $ref = { content_type => $args->{content_type} } if ($args->{content_type});
   $self->{elem} = HTML::Accessors->new( $ref );

   $suffix = $args->{content_type} && $args->{content_type} eq q(text/html)
           ? q(>) : q( />);

   # Bare minimum is fields + id to get a useful widget
   for (qw(ajaxid fields id name)) {
      $self->{ $_ } = $args->{ $_ } if (exists $args->{ $_ });
   }

   # Defaults id from name (least significant) from id from ajaxid (most sig.)
   $self->{id} = $self->{ajaxid} if (!$self->{id} && $self->{ajaxid});

   if (!$self->{name} && $self->{id}) {
      if ($self->{id} =~ m{ \. }mx) {
         (undef, $self->{name}) = split m{ \. }mx, $self->{id};
      }
      else { ($self->{name}) = reverse split m{ _ }mx, $self->{id} }
   }

   $self->{id} = $self->{name} if (!$self->{id} && $self->{name});

   # Get static attributes for this id from the fields passed in $args
   if ($self->{id}
       && $self->{fields}
       && defined $self->{fields}->{ $self->{id} }) {
      for (@STATIC) {
         if (defined( $val = $self->{fields}->{ $self->{id} }->{ $_ } )) {
            $self->{ $_ } = $val;
         }
      }
   }

   # Passed args override XML config
   for (grep { exists $self->{ lc $_ } } keys %{ $args }) {
      $self->{ lc $_ } = $args->{ $_ };
   }

   # We can get the widget type from the fields in level.xml
   if ( ! $self->{type}
       && $self->{id}
       && $self->{fields}
       && $self->{fields}->{ $self->{id} }
       && $self->{fields}->{ $self->{id} }->{type}) {
      $self->{type} = $self->{fields}->{ $self->{id} }->{type};
   }

   $self->{type} = q(textfield) unless ($self->{type});

   # Your basic factory method trick
   $class = __PACKAGE__.q(::).(ucfirst $self->{type});
   ## no critic
   eval "require $class;";
   ## critic

   if ($EVAL_ERROR) {
      $self->{text} = $EVAL_ERROR; $self->{type} = undef;
   }

   bless $self, $class;

   $self->{nodeId} = q(node_0); # Define accessor by hand to auto increment

   $self->text_obj( Text::Markdown->new
                    ( empty_element_suffix => $suffix,
                      tab_width            => $self->tabstop ) );

   # Pander to lazy filling out of static definitions
   $self->container( $self->type =~ m{ chooser|file|label|note }mx ? 0 : 1 )
      unless (defined $self->container);

   if ($self->ajaxid) {
      $msg_id = $self->fields
              ? $self->fields->{ $self->ajaxid }->{validate}
              : $NUL;
      $msg_id = $msg_id->[0] if (ref $msg_id eq q(ARRAY));
      $text   = $self->msg( $msg_id ) || 'Invalid field value';
      $self->ajaxtext( $text );

      # Install default JavaScript event handler
      unless ($self->onblur || $self->onchange || $self->onkeypress) {
         $text = $self->evnt_hndlr.'(\''.$self->ajaxid.'\', this.value)';
         $self->onblur( $text );
      }
   }

   $self->hint_title( $text ) if ($text = $self->msg( q(handy_hint_title) ));

   unless (defined $self->height) {
      $self->height( $self->type eq q(groupMembership) ||
                     $self->type eq q(scrollingList) ? 10 : 5 );
   }

   if ($self->pwidth && ($self->pwidth =~ m{ \A \d+ \z }mx)) {
      $self->pwidth( (int $self->pwidth * $self->swidth / 100).q(px) );
   }

   $self->sep( $NUL ) if ($self->type eq q(note));
   $self->sep( $NUL ) if (!$self->prompt && !$self->fhelp);
   $self->sep( $NUL ) if ($self->sep =~ m{ \A \d+ \z }mx && $self->sep == 0);
   $self->sep( $self->space ) if ($self->sep && $self->sep eq q(space));

   if (defined $self->stepno && $self->stepno == 0) {
      $self->stepno( $self->space );
   }

   if ($self->stepno && $self->stepno ne $self->space) {
      $self->stepno( $self->stepno.q(.) );
   }

   return $self;
}

# Object methods

sub msg {
   # Return the language dependant text of the requested message
   my ($me, $name, $args) = @_; my ($key, $msgs, $pat, $text, $val);

   return q() unless ($name && ($msgs = $me->messages));

   if (exists $msgs->{ $name } && ($text = $msgs->{ $name }->{text})) {
      if ($msgs->{ $name }->{markdown}) {
         $text = $me->text_obj->markdown( $text );
      }

      if ($args) {
         # Inflate arg values enclosed in [%%]
         for $key (keys %{ $args }) {
            $pat  = q(\[% \s+ ).$key.q( \s+ %\]);
            $val  = $args->{ $key } || q();
            $text =~ s{ $pat }{$val}gmx;
         }
      }
   }
   else { $text = q() }

   return $text;
}

sub render {
   my $me = shift; my ($field, $htag, $html, $method, $ref, $tip);

   return $me->text || $NUL unless ($me->type);

   $htag  = $me->elem;
   $html  = $me->clear eq q(left) ? $htag->br() : "\n";

   if ($me->stepno) {
      $html .= $htag->span( { class => q(lineNumber) }, $me->stepno );
   }

   if ($me->prompt) {
      $ref           = { class => q(prompt) };
      $ref->{for  }  = $me->id                         if ($me->id);
      $ref->{style} .= 'text-align: '.$me->palign.'; ' if ($me->palign);
      $ref->{style} .= 'white-space: nowrap; '         if ($me->nowrap);
      $ref->{style} .= 'width: '.$me->pwidth.q(;)      if ($me->pwidth);
      $html         .= $htag->label( $ref, $me->prompt );
   }

   if ($me->type eq q(groupMembership)) {
      $ref           = { class => q(instructions) };
      $ref->{style} .= 'text-align: '.$me->palign.'; ' if ($me->palign);
      $ref->{style} .= 'width: '.$me->pwidth.q(;)      if ($me->pwidth);
      $html         .= $htag->div( $ref, $me->fhelp );
   }

   $html .= $htag->div( { class => q(separator) }, $me->sep ) if ($me->sep);

   $ref               = {};
   $ref->{class     } = q(required)     if ($me->required);
   $ref->{default   } = $me->default    if ($me->default);
   $ref->{id        } = $me->id         if ($me->id);
   $ref->{name      } = $me->name       if ($me->name);
   $ref->{onblur    } = $me->onblur     if ($me->onblur);
   $ref->{onkeypress} = $me->onkeypress if ($me->onkeypress);

   return $html unless ($field = $me->_render( $ref ));

   if ($tip = $me->tip) {
      $tip =~ s{ \n }{ }gmx;
      $tip = $me->hint_title.$TTS.$tip if ($tip !~ m{ $TTS }mx);
      $tip =~ s{ \s+ }{ }gmx;
      $ref = { class => q(help tips), title => $tip };

      if ($me->tiptype ne q(dagger)) { $field = $htag->span( $ref, $field ) }
      else { $field .= $htag->span( $ref, $me->nb_symbol ) }
   }

   if ($me->container) {
      $ref   = { class => q(container ).$me->align };
      $field = $htag->div( $ref, $field );
   }

   if ($me->ajaxid) {
      $ref    = { class => q(hidden), id => $me->ajaxid.q(_checkField) };
      $field .= $htag->div( $ref, $htag->br().$me->ajaxtext );
      $ref    = { class => q(container) };
      $field  = $htag->div( $ref, $field );
   }

   return $html.$field;
}

# Private methods

sub _arg_list {
   my ($me, @rest) = @_;

   return {} unless ($rest[0]);

   return ref $rest[0] eq q(HASH) ? $rest[0] : { @rest };
}

sub _group_fields {
   my ($me, $item, $list) = @_; my $html = $NUL; my $ref;

   for (1 .. $item->{content}->{nitems}) {
      $ref  = pop @{ $list }; chomp $ref->{content};
      $html = $ref->{content}.$html;
   }

   my $htag   = HTML::Accessors->new();
   my $legend = $htag->legend( $item->{content}->{text} );
   return "\n".$htag->fieldset( "\n".$legend.$html );
}

sub _merge_config {
   my ($me, $config, $item) = @_;

   return { %{ $config }, %{ $item->{content} } };
}

sub _render {
   my ($me, $ref) = @_;

   return $me->text if ($me->text);

   return 'No _render method for field '.($ref->{id} || '*unknown id*');
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets - Create HTML form markup

=head1 Version

0.1.$Rev$

=head1 Synopsis

   package MyApp::View::HTML;

   use base qw(CatalystX::Usul::View::HTML);
   use HTML::FormWidgets;

   sub build_form {
      my ($me, $c) = @_;
      my $s        = $c->stash;
      my $form     = [ $s->{iFrame} ];
      my $config   = {};

      $config->{root        } = $c->config->{root};
      $config->{base        } = $c->req->base;
      $config->{content_type} = $c->config->{content_type};
      $config->{url         } = $c->req->path;
      $config->{assets      } = $s->{assets};
      $config->{fields      } = $s->{fields} || {};
      $config->{form        } = $s->{form};
      $config->{hide        } = $s->{iFrame}->{hidden};
      $config->{messages    } = $s->{messages};
      $config->{swidth      } = $s->{width} if ($s->{width});
      $config->{templatedir } = $c->config->{dynamic_templates};

      HTML::FormWidgets->build( $config, $form );
      return;
   }

=head1 Description

Transforms a Perl data structure which defines one or more "widgets"
into HTML or XHTML. Each widget is comprised of these optional
components: a line or question number, a prompt string, a separator,
an input field, additional field help, and Ajax field error string.

Input fields are selected by the widget C<type> attribute. A factory
subclass implements the method that generates the HTML or XHTML for
that input field type. Adding more widget types is straightforward

This module is using the MooTools Javascript library
L<http://mootools.net/> to modify default browser behaviour

This module is used by L<CatalystX::Usul::View::HTML> and as such its
main use is a form generator within a L<Catalyst> application

=head1 Subroutines/Methods

=head2 build

The C<build> method iterates over a data structure that represents the
form. One or more lists of widgets are processed in turn. New widgets
are created and their rendered output replaces their definitions in the
data structure

=head2 new

Construct a widget. Mostly this is called by the C<build> method. It
requires the factory subclass for the widget type.

This method takes a large number of options with each widget using
only few of them. Each option is described in the factory subclasses
which use that option

=head2 msg

Use the supplied key to return a value from the B<messages>
hash. This hash was passed to the constructor and should contain any
literal text used by any of the widgets

=head2 render

Assemble the components of the generated widget. Each component is
concatenated onto a scalar which is the returned value. This method
calls C<_render> which should be defined in the factory subclass for
this widget type.

This method uses these attributes:

=over 3

=item clear

If set to B<left> the widget begins with an <br> element

=item stepno

If true it's value is wrapped in a B<span> element of class B<lineNumber>
and appended to the return value

=item prompt

If true it's value is wrapped in a B<label> element of class B<prompt> and
appended to the return value. The B<id> attribute is used to
set the B<for> attribute of the B<label> element.  The
B<palign> attribute sets the text align style for the
B<label> element. The B<nowrap> attribute sets whitespace
style to nowrap in the B<label> element. The B<pwidth>
attribute sets the width style attribute in the B<label> element

=item sep

If true it's value is wrapped in a B<div> element of class B<separator>
and appended to the return value

=item container

If true the value return by the C<_render> method is wrapped in B<div>
element of classes B<container> and B<align>

=item tip

The text of the field help. If B<tiptype> is set to B<dagger>
(which is the default) then a dagger symbol B<nb_symbol> is
wrapped in a B<span> of class B<help tips> and this is appended to the
returned input field.  The tip text is used as the B<title>
attribute. If the B<tiptype> is not set to B<dagger> then the help
text is wrapped around the input field itself

=item ajaxid

The text of the message which is displayed if the field's value fails
server side validation

=back

=head2 _arg_list

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

=head2 _group_fields

Wraps the top B<nitems> widgets on the build stack in a fieldset
element with a legend

=head2 _merge_config

Does a simple merging of the two hash refs that are passed as
arguments. The second argument takes precedence over the first

=head2 _render

This should have been overridden in the factory subclass. If it gets
called its probably an error so return the value of our C<text>
attribute if set or an error message otherwise

=head1 Configuration and Environment

The following are passed to C<build> in the B<config> hash (they
reflect this modules primary use within a L<Catalyst> application):

=over 3

=item assets

Some of the widgets require image files. This attribute is used to
create the URI for those images

=item base

This is the prefix for our URI

=item content_type

Either I<application/xhtml+xml> which generates XHTML 1.1 and is the
default or I<text/html> which generates HTML 4.01

=item fields

This hash ref contains the fields definitions. Static parameters for
each widget can be stored in configuration files. This reduces the
number of attributes that have to be passed in the call to the
constructor

=item form

Used by the C<::Chooser> subclass

=item hide

So that the C<::File> and C<::Table> subclasses can store the number
of rows added as the hidden form variable B<nRows>

=item messages

Many of the subclasses use this hash to supply literal text in a
language of the users choosing

=item root

The path to the document root for this application

=item swidth

Width in pixels of the browser window. This is used to calculate the
width of the field prompt. The field prompt needs to be a fixed length
so that the separator colons align vertically

=item templatedir

The path to template files used by the C<::Template> subclass

=item url

Only used by the C<::Tree> subclass to create self referential URIs

=back

Sensible defaults are provided by C<new> if any of the above are undefined

=head1 Factory Subclasses

These are the possible values for the B<type> attribute which defaults
to I<textfield>. Each subclass implements the C<_render> method, it
receives a hash ref of options an returns a scalar containing some
XHTML.

The distribution ships with the following factory subclasses:

=head2 Anchor

Returns an B<anchor> element of class option B<class> (which defaults
to I<linkFade>) with it's B<href> attribute set to the B<href>
option. The anchor body is set to the B<text> option

=head2 Checkbox

Return a B<checkbox> element of value B<value>. Use the
element's value as key to the B<labels> hash. The hash value
(which defaults null) is used as the displayed label. The
B<checked> option determines the checkbox's initial
setting

=head2 Chooser

Creates a popup window which allows one item to be selected from a
B<long> list of items

=head2 Cloud

Creates list of links from the data set supplied in the I<data> option

=head2 Date

Return another text field, this time with a calendar icon which when
clicked pops up a Javascript date picker. Requires the appropriate JS
library to have been loaded by the page. Attribute B<width>
controls the size of the textfield (default 10 characters) and
B<format> defaults to I<dd/mm/yyyy>

=head2 File

Display the contents of a file pointed to by B<path>. Supports the
following subtypes:

=over 3

=item csv

Return a table containing the CSV formatted file. This and the I<file>
subtype are selectable if B<select> >= 0 and represents the
column number of the key field

=item file

Default subtype. Like the logfile subtype but without the B<pre> tags

=item html

The C<_render> method returns an B<iframe> tag whose B<src> attribute
is set to B<path>. Paths that begin with B<root>
will have that replaced with B<base>. Paths that do not begin
with "http:" will have B<base> prepended to them

=item logfile

The C<_render> method returns a table where each line of the logfile
appears as a separate row containing one cell. The logfile lines are
each wrapped in B<pre> tags

=item source

The module C<Syntax::Highlight::Perl> is used to provide colour
highlights for the Perl source code. Tabs are expanded to
B<tabstop> spaces and the result is returned wrapped in
B<pre> tags

=back

=head2 Freelist

New values entered into a text field can be added to the
list. Existing list values (passed in B<values>) can be
removed. The height of the list is set by B<height>.

=head2 GroupMembership

Displays two lists which allow for membership of a group. The first
scrolling list contains "all" values (B<all>), the second
contains those values currently selected (B<current>). The
height of the scrolling lists is set by B<height>

=head2 ImageButton

Generates an image button where B<name> identifies the image
file in B<assets> and is also used as the return value. The
button name is set to I<_verb>

=head2 Label

Calls B<msg> with B<name> as the message key. If the
text does not exist B<text> is used. If B<dropcap>
is true the first character of the text is wrapped in a B<span> of
class I<dropcap>

=head2 Note

Calls B<msg> with B<name> as the message key. If the
text does not exist B<text> is used. The text is wrapped in a
B<div> of class I<note> with B<align> setting the style text
alignment and B<width> setting the style width

=head2 Password

Returns a password field of width B<width> which defaults to
twenty characters. If B<subtype> equals I<verify> then the
message I<vPasswordPrompt> and another password field are
appended. The fields B<id> and B<name> are expected
to contain the digit 1 which will be substituted for the digit 2 in
the attributes of the second field

=head2 PopupMenu

Returns a list of B<option> elements wrapped in a B<select>
element. The list of options is passed in B<values> with the
display labels in B<labels>. The onchange event handler will
be set to B<onchange>

=head2 RadioGroup

The attribute B<columns> sets the number of columns for the
returned table of radio buttons. The list of button values is passed in
B<values> with the display labels in B<labels>. The
onchange event handler will be set to B<onchange>

=head2 Rule

Generates a horizontal rule with optional clickable action

=head2 ScrollingList

The B<height> attribute controls the height of the scrolling
list.  The list of options is passed in B<values> with the
display labels in B<labels>. The onchange event handler will
be set to B<onchange>

=head2 Table

The input data is in B<data-E<gt>{values}> which is an array
ref for which each element is an array ref containing the list of
field values.

=head2 Template

Look in B<templatedir> for a L<Template::Toolkit> template
called B<id> with a I<.tt> extension. Slurp it in and return
it as the content for this widget. This provides for a "user defined"
widget type

=head2 Textarea

A text area. It defaults to five lines high (B<height>) and
sixty characters wide (B<width>)

=head2 Textfield

This is the default widget type. Your basic text field which defaults
to sixty characters wide (B<width>)

=head2 Tree

Implements an expanding tree of selectable objects. See L<Bugs and
Limitations>

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Data::Accessor>

=item L<HTML::Accessors>

=item L<Readonly>

=item L<Syntax::Highlight::Perl>

=item L<Text::Markdown>

=item L<Text::ParseWords>

=item L<Text::Tabs>

=back

Included in the distribution are the Javascript files whose methods
are called by the event handlers associated with these widgets

=head2 10htmlparser.js

   HTML Parser By John Resig (ejohn.org)
   Original code by Erik Arvidsson, Mozilla Public License
   http://erik.eae.net/simplehtmlparser/simplehtmlparser.js

Used to reimplement "innerHTML" assignments from XHTML

=head2 20mootools.js

   Mootools - My Object Oriented javascript.
   License: MIT-style license.
   WWW: http://mootools.net/

This is the main JS library used with this package

=head2 30ourtools.js

Replaces Mootools' C<setHTML> method with one that uses the HTML
parser. The included copy has a few hacks that improve the Accordion
widget

=head2 40calendar.js

   Author: Matt Kruse <matt@mattkruse.com>
   WWW: http://www.mattkruse.com/

which has a license restriction that prevents inclusion in
other distributions so I'll drop this at the next release. Only used by
C<::Date> subclass

=head2 behaviour.js

Is included from the L<App::Munchies> default skin. It uses the
MooTools library to implement the server side field validation

Also included in the C<images> subdirectory of the distribution are
example PNG files used by some of the widgets.

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

The Javascript for the B<tree> widget is not included due to copyright
issues, so that widget doesn't work. Same for the B<date> widget except
that there is a link in L<Dependencies> to a web site where the
Javascript might be available

The installation script does nothing with the Javascript or PNG files
which are included in the distribution for completeness

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2008 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:

