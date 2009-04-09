package HTML::FormWidgets;

# @(#)$Id$

use strict;
use warnings;
use parent qw(Class::Accessor::Fast);
use Class::Inspector;
use English qw(-no_match_vars);
use HTML::Accessors;
use Text::Markdown qw(markdown);

use version; our $VERSION = qv( '0.3' );

my $NB    = q(&nbsp;&dagger;);
my $NUL   = q();
my $SPC   = q( );
my $TTS   = q( ~ );
my $ATTRS =
   { ajaxid          => undef,             ajaxtext        => undef,
     align           => q(left),           class           => $NUL,
     clear           => $NUL,              container       => 1,
     container_class => undef,             container_id    => undef,
     content_type    => q(text/html),      default         => undef,
     evnt_hndlr      => q(behaviour.server.checkField),
     hacc            => undef,             hint_title      => $NUL,
     id              => undef,             is_xml          => 0,
     messages        => {},                name            => undef,
     nowrap          => 0,
     onblur          => undef,             onchange        => undef,
     onkeypress      => undef,             palign          => undef,
     prompt          => $NUL,              pwidth          => 40,
     required        => 0,                 sep             => undef,
     space           => q(&nbsp;) x 3,     stepno          => undef,
     swidth          => 1000,              tabstop         => 3,
     text            => $NUL,              text_obj        => undef,
     tip             => $NUL,              tiptype         => q(dagger),
     type            => undef, };

__PACKAGE__->mk_accessors( keys %{ $ATTRS } );

__PACKAGE__->mk_accessors( qw(_fields _messages) );

# Class methods

sub build {
   my ($class, $config, $data) = @_;

   my $key  = $config->{list_key    } || q(items);
   my $type = $config->{content_type} || $ATTRS->{content_type};

   $config->{hacc} = HTML::Accessors->new( content_type => $type );

   for my $list (grep { $_ and ref $_ eq q(HASH) } @{ $data }) {
      my @tmp = ();

      for my $item (@{ $list->{ $key } }) {
         my $built = __build_widget( $class, $config, $item, \@tmp );

         push @tmp, $built if ($built);
      }

      @{ $list->{ $key } } = @tmp;
   }

   return;
}

sub new {
   my ($class, @rest) = @_;

   # Coerce a hash ref of the passed args
   my $args = __arg_list( @rest );

   # Start with some hard coded defaults;
   my $self = bless { %{ $ATTRS } }, $class;

   # Set minimum requirements from the supplied args and the defaults
   $self->_bootstrap( $args );

   # Your basic factory method trick
   $class = __PACKAGE__.q(::).(ucfirst $self->type);
   $self->_ensure_class_loaded( $class );

   # Complete the initialization
   $self->init( $args );

   return $self;
}

# Object methods

sub inflate {
   my ($self, $args) = @_;

   return unless ($args);

   return $args unless (ref $args);

   $args->{fields}   = $self->_fields;
   $args->{messages} = $self->_messages;

   return __PACKAGE__->new( $args )->render;
}

sub init {
   my ($self, $args) = @_;

   # Allow the factory subclass to set it's own defaults
   $self->_init( $args );

   my $skip   = { qw(ajaxid 1 id 1 name 1 type 1) };
   my $fields = $args->{fields};

   $self->_init_fields( $skip, $fields );
   $self->_init_args (  $skip, $args );

   my $content_type = $self->content_type;

   $self->is_xml( $content_type eq q(text/html) ? 0 : 1 );

   # Now we can create HTML elements like we could with CGI.pm
   unless ($self->hacc) {
      $self->hacc( HTML::Accessors->new( { content_type => $content_type } ) );
   }

   # Create a Text::Markdown object for use by the msg method
   $self->text_obj( Text::Markdown->new
                    ( empty_element_suffix => $self->is_xml ? q( />) : q(>),
                      tab_width            => $self->tabstop ) );

   # Set the ajax field validation message
   $self->_init_ajax_text( $fields ) if ($self->ajaxid);

   # Calculate the prompt width
   my $pwidth = $self->pwidth;

   if ($pwidth and $pwidth =~ m{ \A \d+ \z }mx) {
      $self->pwidth( (int $pwidth * $self->swidth / 100).q(px) );
   }

   my $sep = $self->sep;

   $sep = q(&nbsp;:&nbsp;) if (not defined $sep and $self->prompt);
   $sep = $self->space     if (    defined $sep and $sep eq q(space));

   $self->sep( $sep );

   my $stepno = $self->stepno;

   $stepno = $self->space if (defined $stepno and $stepno == 0);
   $stepno = $stepno.q(.) if ($stepno and $stepno ne $self->space);

   $self->stepno( $stepno );
   return;
}

*loc = \&localize;

sub localize {
   my ($self, $key, @args) = @_; my $text;

   return unless $key;

   $key = $NUL.$key if ($key); # I hate Return::Value

   my $message = $self->messages->{ $key };

   if ($message and $text = $message->{text}) {
      $text = $self->text_obj->markdown( $text ) if ($message->{markdown});
   }
   else { $text = $key if ($key =~ m{ \s+ }mx) }

   return $NUL unless ($text);

   @args = @{ $args[ 0 ] } if ($args[ 0 ] && ref $args[ 0 ] eq q(ARRAY));

   if ((index $text, "\[") >= 0 and $text =~ m{ \[ _ \d+ \] }mx) {
      push @args, ( q() x 10 );
      $text =~ s{ \[ _ (\d+) \] }{$args[ $1 - 1 ]}gmx;
   }
   else { $text .= $SPC.(join $SPC, @args) }

   return $text;
}

sub render {
   my $self = shift; my $field;

   return $self->text || $NUL unless ($self->type);

   my $hacc = $self->hacc;
   my $html = "\n".($self->clear eq q(left) ? $hacc->br() : $NUL);

   if ($self->stepno) {
      $html .= $hacc->span( { class => q(lineNumber) }, $self->stepno );
   }

   $html .= $self->_render_prompt_label( $hacc ) if ($self->prompt);

   if ($self->sep) {
      $html .= $hacc->span( { class => q(separator) }, $self->sep );
   }

   return $html unless ($field = $self->_render_field);

   $field = $self->_render_tip(         $hacc, $field ) if ($self->tip);
   $field = $self->_render_container(   $hacc, $field ) if ($self->container);
   $field = $self->_render_check_field( $hacc, $field ) if ($self->ajaxid);

   return $html.$field;
}

# Private object methods

sub _bootstrap {
   my ($self, $args) = @_;

   # Bare minimum is fields + id to get a useful widget
   for (grep { exists $args->{ $_ } } qw(ajaxid id name type)) {
      $self->{ $_ } = $args->{ $_ };
   }

   # Defaults id from name (least significant) from id from ajaxid (most sig.)
   my $id = $self->id; my $name = $self->name; my $type = $self->type;

   $id = $self->id( $self->ajaxid ) if (not $id and $self->ajaxid);

   if ($id and not $name) {
      if ($id =~ m{ \. }mx) {
         $name = $self->name( (split m{ \. }mx, $id)[1] );
      }
      else { $name = $self->name( (reverse split m{ _ }mx, $id)[0] ) }
   }

   $id = $self->id( $name ) if (not $id and $name);

   # We can get the widget type from the config file
   if (not $type and $id and exists $args->{fields}) {
      my $fields = $args->{fields};

      if (exists $fields->{ $id } and exists $fields->{ $id }->{type}) {
         $type = $self->type( $fields->{ $id }->{type} );
      }
   }

   # This is the default widget type if not overidden in the config
   $type = $self->type( q(textfield) ) unless ($type);

   $self->name     ( $type             ) unless ($name);
   $self->_fields  ( $args->{fields  } );
   $self->_messages( $args->{messages} );
   return;
}

sub _ensure_class_loaded {
   my ($self, $class) = @_; my $error;

   ## no critic
   {  local $EVAL_ERROR; eval "require $class;"; $error = $EVAL_ERROR; }
   ## critic

   return $self->_set_error( $error ) if ($error);

   unless (Class::Inspector->loaded( $class )) {
      return $self->_set_error( "Failed to load class $class" );
   }

   bless $self, $class;
   return;
}

sub _init {
   # Can be overridden in factory subclass
}

sub _init_ajax_text {
   my ($self, $fields) = @_; my $ajax_id = $self->ajaxid; my ($msg_id, $text);

   $msg_id = exists $fields->{ $ajax_id }
           ? $fields->{ $ajax_id }->{validate} : $NUL;
   $msg_id = $msg_id->[0] if ($msg_id and ref $msg_id eq q(ARRAY));
   $text   = $self->ajaxtext
          || ($msg_id && $self->loc( $msg_id ))
          || 'Invalid field value';
   $self->ajaxtext( $text );

   # Install default JavaScript event handler
   unless ($self->onblur || $self->onchange || $self->onkeypress) {
      $text = $self->evnt_hndlr.'( "'.$self->ajaxid.'", this.value )';
      $self->onblur( $text );
   }

   return;
}

sub _init_args {
   my ($self, $skip, $args) = @_; my $val;

   for (grep { not $skip->{ $_ } } keys %{ $args }) {
      if (exists $self->{ $_ } and defined ($val = $args->{ $_ })) {
         $self->{ $_ } = $val;
      }
   }

   return;
}

sub _init_fields {
   my ($self, $skip, $fields) = @_; my $id = $self->id; my $val;

   if ($id && $fields && exists $fields->{ $id }) {
      my $field = $fields->{ $id };

      for (grep { not $skip->{ $_ } } keys %{ $field }) {
         if (exists $self->{ $_ } and defined ($val = $field->{ $_ })) {
            $self->{ $_ } = $val;
         }
      }
   }

   return;
}

sub _render {
   my ($self, $args) = @_;

   return $self->text if ($self->text);

   my $id = $args->{id} || '*unknown id*';
   $self->_set_error( "No _render method for field $id" );
   return;
}

sub _render_check_field {
   my ($self, $hacc, $field) = @_; my $args;

   $args   = { class => q(hidden), id => $self->ajaxid.q(_checkField) };
   $field .= $hacc->div( $args, $hacc->br().$self->ajaxtext );
   $args   = { class => $self->container_class || q(container) };

   return $hacc->div( $args, $field );
}

sub _render_container {
   my ($self, $hacc, $field) = @_; my ($args, $class);

   unless ($class = $self->container_class) {
      $class = q(container ).$self->align;
   }

   $args       = { class => $class };
   $args->{id} = $self->container_id if ($self->container_id);

   return $hacc->div( $args, $field );
}

sub _render_field {
   my $self = shift; my $args = {}; my $id = $self->id; my $name = $self->name;

   $args->{class     } = q(required)       if ($self->required);
   $args->{default   } = $self->default    if ($self->default);
   $args->{id        } = $id               if ($id);
   $args->{name      } = $name             if ($name);
   $args->{onblur    } = $self->onblur     if ($self->onblur);
   $args->{onkeypress} = $self->onkeypress if ($self->onkeypress);

   return $self->_render( $args );
}

sub _render_prompt_label {
   my ($self, $hacc) = @_; my $args = { class => q(prompt) };

   $args->{for  }  = $self->id                         if ($self->id);
   $args->{style} .= 'text-align: '.$self->palign.'; ' if ($self->palign);
   $args->{style} .= 'white-space: nowrap; '           if ($self->nowrap);
   $args->{style} .= 'width: '.$self->pwidth.q(;)      if ($self->pwidth);

   return $hacc->label( $args, $self->prompt );
}

sub _render_tip {
   my ($self, $hacc, $field) = @_; my ($args, $tip);

   ($tip = $self->tip) =~ s{ \n }{ }gmx;

   if ($tip !~ m{ $TTS }mx) {
      unless ($self->hint_title) {
         $self->hint_title( $self->loc( q(handy_hint_title) ) );
      }

      $tip = $self->hint_title.$TTS.$tip;
   }

   $tip  =~ s{ \s+ }{ }gmx;
   $args = { class => q(help tips), title => $tip };

   return $hacc->span( $args, $field ) if ($self->tiptype ne q(dagger));

   return $field.$hacc->span( $args, $NB );
}

sub _set_error {
   my ($self, $error) = @_; $self->{text} = $error; return;
}

# Private subroutines (not methods)

sub __arg_list {
   my (@rest) = @_;

   return {} unless ($rest[0]);

   return ref $rest[0] eq q(HASH) ? $rest[0] : { @rest };
}

sub __build_widget {
   my ($class, $config, $item, $stack) = @_;

   return unless ($item);

   return $item unless (ref $item and ref $item->{content} eq q(HASH));

   if ($item->{content}->{group}) {
      return if ($config->{skip_groups});

      $item->{content} = __group_fields( $config->{hacc}, $item, $stack );
   }
   elsif ($item->{content}->{widget}) {
      my $widget = $class->new( __merge_config( $config, $item ) );

      $item->{content} = $widget->render;
      $item->{class  } = $widget->class if ($widget->class);
   }

   return $item;
}

sub __group_fields {
   my ($hacc, $item, $list) = @_; my $html = $NUL; my $args;

   for (1 .. $item->{content}->{nitems}) {
      $args = pop @{ $list };
      $args->{content} ||= $NUL; chomp $args->{content};
      $html = $args->{content}.$html;
   }

   my $legend = $hacc->legend( $item->{content}->{text} );

   return "\n".$hacc->fieldset( "\n".$legend.$html );
}

sub __merge_config {
   my ($config, $item) = @_; return { %{ $config }, %{ $item->{content} } };
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets - Create HTML form markup

=head1 Version

$Rev$

=head1 Synopsis

   package MyApp::View::HTML;

   use base qw(CatalystX::Usul::View::HTML);
   use HTML::FormWidgets;

   sub build_widgets {
      my ($self, $c, $data, $config) = @_; my $s = $c->stash; $config ||= {};

      $config->{assets      } = $s->{assets};
      $config->{base        } = $c->req->base;
      $config->{content_type} = $s->{content_type};
      $config->{fields      } = $s->{fields} || {};
      $config->{form        } = $s->{form};
      $config->{hide        } = $s->{hidden}->{items};
      $config->{messages    } = $s->{messages};
      $config->{pwidth      } = $s->{pwidth};
      $config->{root        } = $c->config->{root};
      $config->{swidth      } = $s->{width} if ($s->{width});
      $config->{templatedir } = $self->dynamic_templates;
      $config->{url         } = $c->req->path;

      HTML::FormWidgets->build( $config, $data );
      return $data;
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

   $self = $class->new( [{] key1 => value1, ... [}] );

Construct a widget. Mostly this is called by the L</build> method. It
requires the factory subclass for the widget type.

This method takes a large number of options with each widget using
only few of them. Each option is described in the factory subclasses
which use that option

=head2 inflate

Creates new C<HTML::FormWidgets> objects and returns their rendered output.
Called by the L</_render> methods in the factory subclasses to inflate
embeded widget definitions

=head2 init

   $self->init( $args );

Initialises this object with data from the passed arguments. This is
usually overridden in the factory subclass which sets the default for
it's own attributes and then calls this method in the base class

=head2 localize

   $message_text = $self->localize( $message_id );

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
(which is the default) then a dagger symbol is
wrapped in a B<span> of class B<help tips> and this is appended to the
returned input field.  The tip text is used as the B<title>
attribute. If the B<tiptype> is not set to B<dagger> then the help
text is wrapped around the input field itself

=item ajaxid

The text of the message which is displayed if the field's value fails
server side validation

=back

=head2 _bootstrap

Determine the C<id>, C<name> and C<type> of the widget from the supplied
arguments

=head2 _ensure_class_loaded

Once the factory subclass is known this method ensures that it is loaded
and then re-blesses the self referential object into the correct class

=head2 _render

This should have been overridden in the factory subclass. If it gets
called its probably an error so return the value of our C<text>
attribute if set or an error message otherwise

=head2 _set_error

Stores the passed error message in the C<text> attribute so that it
gets rendered in place of the widget

=head2 __arg_list

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

=head2 __group_fields

Wraps the top B<nitems> widgets on the build stack in a fieldset
element with a legend

=head2 __merge_config

Does a simple merging of the two hash refs that are passed as
arguments. The second argument takes precedence over the first

=head1 Configuration and Environment

The following are passed to C<build> in the I<config> hash (they
reflect this modules primary use within a L<Catalyst> application):

=over 3

=item assets

Some of the widgets require image files. This attribute is used to
create the URI for those images

=item base

This is the prefix for our URI

=item content_type

Either I<application/xhtml+xml> which generates XHTML 1.1 or
I<text/html> which generates HTML 4.01 and is the default

=item fields

This hash ref contains the fields definitions. Static parameters for
each widget can be stored in configuration files. This reduces the
number of attributes that have to be passed in the call to the
constructor

=item form

Used by the C<::Chooser> subclass

=item hide

So that the C<::File> and C<::Table> subclasses can store the number
of rows added as the hidden form variable I<nRows>

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

These are the possible values for the I<type> attribute which defaults
to I<textfield>. Each subclass implements the C<_render> method, it
receives a hash ref of options an returns a scalar containing some
XHTML.

The distribution ships with the following factory subclasses:

=head2 Anchor

Returns an I<anchor> element of class option I<class> (which defaults
to I<linkFade>) with it's I<href> attribute set to the I<href>
option. The anchor body is set to the I<text> option

=head2 Checkbox

Return a I<checkbox> element of value I<value>. Use the
element's value as key to the I<labels> hash. The hash value
(which defaults null) is used as the displayed label. The
I<checked> option determines the checkbox's initial
setting

=head2 Chooser

Creates a popup window which allows one item to be selected from a
I<long> list of items

=head2 Cloud

Creates list of links from the data set supplied in the I<data> option

=head2 Date

Return another text field, this time with a calendar icon which when
clicked pops up a Javascript date picker. Requires the appropriate JS
library to have been loaded by the page. Attribute I<width>
controls the size of the textfield (default 10 characters) and
I<format> defaults to I<dd/mm/yyyy>. Setting the I<readonly> attribute
to true (which is the default) causes the input textfield to become
readonly

=head2 File

Display the contents of a file pointed to by I<path>. Supports the
following subtypes:

=over 3

=item csv

Return a table containing the CSV formatted file. This and the I<file>
subtype are selectable if I<select> >= 0 and represents the
column number of the key field

=item file

Default subtype. Like the logfile subtype but without the I<pre> tags

=item html

The C<_render> method returns an I<iframe> tag whose I<src> attribute
is set to I<path>. Paths that begin with I<root>
will have that replaced with I<base>. Paths that do not begin
with "http:" will have I<base> prepended to them

=item logfile

The C<_render> method returns a table where each line of the logfile
appears as a separate row containing one cell. The logfile lines are
each wrapped in I<pre> tags

=item source

The module C<Syntax::Highlight::Perl> is used to provide colour
highlights for the Perl source code. Tabs are expanded to
I<tabstop> spaces and the result is returned wrapped in
I<pre> tags

=back

=head2 Freelist

New values entered into a text field can be added to the
list. Existing list values (passed in I<values>) can be
removed. The height of the list is set by I<height>.

=head2 GroupMembership

Displays two lists which allow for membership of a group. The first
scrolling list contains "all" values (I<all>), the second
contains those values currently selected (I<current>). The
height of the scrolling lists is set by I<height>

=head2 Hidden

Generates a hidden input field. Uses the I<default> attribute as the value

=head2 ImageButton

Generates an image button where I<name> identifies the image
file in I<assets> and is also used as the return value. The
button name is set to I<_verb>

=head2 Label

Calls I<msg> with I<name> as the message key. If the
text does not exist I<text> is used. If I<dropcap>
is true the first character of the text is wrapped in a C<span> of
class I<dropcap>

=head2 Menu

Generates an unordered list of links. Used with some applied CSS to
implement a navigation menu

=head2 Note

Calls I<msg> with I<name> as the message key. If the
text does not exist I<text> is used. The text is wrapped in a
I<div> of class I<note> with I<align> setting the style text
alignment and I<width> setting the style width

=head2 Password

Returns a password field of width I<width> which defaults to
twenty characters. If I<subtype> equals I<verify> then the
message I<vPasswordPrompt> and another password field are
appended. The fields I<id> and I<name> are expected
to contain the digit 1 which will be substituted for the digit 2 in
the attributes of the second field

=head2 PopupMenu

Returns a list of I<option> elements wrapped in a I<select>
element. The list of options is passed in I<values> with the
display labels in I<labels>. The onchange event handler will
be set to I<onchange>

=head2 RadioGroup

The attribute I<columns> sets the number of columns for the
returned table of radio buttons. The list of button values is passed in
I<values> with the display labels in I<labels>. The
onchange event handler will be set to I<onchange>

=head2 Rule

Generates a horizontal rule with optional clickable action

=head2 ScrollingList

The I<height> attribute controls the height of the scrolling
list.  The list of options is passed in I<values> with the
display labels in I<labels>. The onchange event handler will
be set to I<onchange>

=head2 Table

The input data is in I<< $data->{values} >> which is an array
ref for which each element is an array ref containing the list of
field values.

=head2 Template

Look in I<templatedir> for a L<Template::Toolkit> template
called I<id> with a I<.tt> extension. Slurp it in and return
it as the content for this widget. This provides for a "user defined"
widget type

=head2 Textarea

A text area. It defaults to five lines high (I<height>) and
sixty characters wide (I<width>)

=head2 Textfield

This is the default widget type. Your basic text field which defaults
to sixty characters wide (I<width>)

=head2 Tree

Implements an expanding tree of selectable objects. See L<Bugs and
Limitations>

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=item L<Class::Inspector>

=item L<HTML::Accessors>

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

   Copyright Mihai Bazon, 2002-2005  |  www.bazon.net/mishoo
   The DHTML Calendar, version 1.0   |  www.dynarch.com/projects/calendar
   License: GNU Lesser General Public License

Implements the calendar popup used by the I<::Date> subclass

=head2 behaviour.js

Is included from the L<App::Munchies> default skin. It uses the
MooTools library to implement the server side field validation

Also included in the C<images> subdirectory of the distribution are
example PNG files used by some of the widgets.

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

The Javascript for the C<::Tree> widget is not included due to copyright
issues, so that widget doesn't work

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

