# @(#)$Id$

package HTML::FormWidgets;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(Class::Accessor::Fast);

use Class::MOP;
use English qw(-no_match_vars);
use HTML::Accessors;
use Text::Markdown qw(markdown);
use TryCatch;

my $LSB   = q([);
my $NB    = '&#160;&dagger;';
my $NUL   = q();
my $SPC   = q( );
my $TTS   = q( ~ );
my $ATTRS =
   { ajaxid          => undef,
     align           => q(left),      class           => $NUL,
     clear           => $NUL,         container       => 1,
     container_class => undef,        container_id    => undef,
     content_type    => q(text/html), default         => undef,
     fields          => {},           frame_class     => $NUL,
     hacc            => undef,        hint_title      => $NUL,
     id              => undef,        is_xml          => 0,
     js_obj          => q(behaviour), messages        => {},
     name            => undef,        nowrap          => 0,
     optional_js     => undef,        onblur          => undef,
     onchange        => undef,        onkeypress      => undef,
     palign          => undef,        prompt          => $NUL,
     pwidth          => 40,           required        => 0,
     sep             => undef,        space           => '&#160;' x 3,
     stepno          => undef,        swidth          => 1000,
     tabstop         => 3,            template_dir    => undef,
     text            => $NUL,
     text_obj        => undef,        tip             => $NUL,
     tiptype         => q(dagger),    type            => undef, };

__PACKAGE__->mk_accessors( keys %{ $ATTRS } );

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

         $built and push @tmp, $built;
      }

      @{ $list->{ $key } } = @tmp;
   }

   return;
}

sub __build_widget {
   my ($class, $config, $item, $stack) = @_; $item or return;

   return $item unless (ref $item and ref $item->{content} eq q(HASH));

   if ($item->{content}->{group}) {
      return if ($config->{skip_groups});

      my $class = delete $item->{content}->{frame_class};

      $item->{content} = __group_fields( $config->{hacc}, $item, $stack );
      $item->{class  } = $class if ($class);
   }
   elsif ($item->{content}->{widget}) {
      my $widget = $class->new( __merge_hashes( $config, $item ) );

      $item->{content} = $widget->render;
      $item->{class  } = $widget->frame_class if ($widget->frame_class);
   }

   return $item;
}

sub __group_fields {
   my ($hacc, $item, $list) = @_; my $html = $NUL; my $args;

   for (1 .. $item->{content}->{nitems}) {
      $args = pop @{ $list }; $html = ($args->{content} || $NUL).$html;
   }

   my $legend = $hacc->legend( $item->{content}->{text} );

   return "\n".$hacc->fieldset( "\n".$legend.$html );
}

sub new {
   my ($self, @rest) = @_;

   # Coerce a hash ref of the passed args
   my $args  = __arg_list( @rest );

   # Start with some hard coded defaults;
   my $new   = bless { %{ $ATTRS } }, ref $self || $self;

   # Set minimum requirements from the supplied args and the defaults
   my $skip  = $new->_bootstrap( $args );

   # Your basic factory method trick
   my $class = ucfirst $new->type;
      $class = (q(+) eq substr $class, 0, 1)
             ? (substr $class, 1) : __PACKAGE__.q(::).$class;

   $new->_ensure_class_loaded( $class );

   # Complete the initialization
   $new->_init( $skip, $args );

   return $new;
}

sub __arg_list {
   my (@rest) = @_; $rest[0] or return {};

   return ref $rest[0] eq q(HASH) ? $rest[0] : { @rest };
}

sub __merge_hashes {
   my ($config, $item) = @_; return { %{ $config }, %{ $item->{content} } };
}

# Public object methods

sub inflate {
   my ($self, $args) = @_;

   defined $args or return; ref $args or return $args;

   $args->{content_type} = $self->content_type;
   $args->{fields      } = $self->fields;
   $args->{messages    } = $self->messages;
   $args->{template_dir} = $self->template_dir;

   return __PACKAGE__->new( $args )->render;
}

sub init {
   # Can be overridden in factory subclass
}

*loc = \&localize;

sub localize {
   my ($self, $key, @rest) = @_;

   $key or return; $key = $NUL.$key; # Stringify

   # Lookup the message using the supplied key
   my $messages = $self->messages     || {};
   my $message  = $messages->{ $key } || {};
   my $text     = $message->{text}    || $key;  # Default msg text to the key

   # Expand positional parameters of the form [_<n>]
   0 > index $text, $LSB and return $text;

   my @args = $rest[0] && ref $rest[0] eq q(ARRAY) ? @{ $rest[0] } : @rest;

   push @args, map { $NUL } 0 .. 10;
   $text =~ s{ \[ _ (\d+) \] }{$args[ $1 - 1 ]}gmx;
   return $text;
}

sub render {
   my $self = shift; my $lead = "\n";

   $self->type or return $self->text || $NUL;

   $self->clear eq q(left) and $lead .= $self->hacc->br();

   $self->stepno and $lead .= $self->render_stepno;
   $self->prompt and $lead .= $self->render_prompt;
   $self->sep    and $lead .= $self->render_separator;

   my $field = $self->_render or return $lead;

   $self->tip       and $field = $self->render_tip        ( $field );
   $self->ajaxid    and $field = $self->render_check_field( $field );
   $self->container and $field = $self->render_container  ( $field );

   return $lead.$field;
}

sub render_check_field {
   my ($self, $field) = @_; my $hacc = $self->hacc;

   my $args = { class => q(hidden), id => $self->ajaxid.q(_ajax) };

   $field .= $hacc->span( $args );

   return $hacc->span( { class => q(field_group) }, $field );
}

sub render_container {
   my ($self, $field) = @_;

   my $args = { class => $self->container_class || q(container ).$self->align };

   $self->container_id and $args->{id} = $self->container_id;

   return $self->hacc->span( $args, $field );
}

sub render_field {
   my ($self, $args) = @_; $self->text and return $self->text;

   my $id = $args->{id} || '*unknown id*';

   return $self->_set_error( "No render_field method for field $id" );
}

sub render_prompt {
   my $self = shift; my $args = { class => q(prompt) };

   $self->id     and $args->{for  }  = $self->id;
   $self->palign and $args->{style} .= 'text-align: '.$self->palign.'; ';
   $self->nowrap and $args->{style} .= 'white-space: nowrap; ';
   $self->pwidth and $args->{style} .= 'width: '.$self->pwidth.q(;);

   return $self->hacc->label( $args, $self->prompt );
}

sub render_separator {
   my $self = shift;

   return $self->hacc->span( { class => q(separator) }, $self->sep );
}

sub render_stepno {
   my $self = shift;

   return $self->hacc->span( { class => q(step_number) }, $self->stepno );
}

sub render_tip {
   my ($self, $field) = @_; my $hacc = $self->hacc;

   (my $tip = $self->tip) =~ s{ \n }{ }gmx;

   if ($tip !~ m{ $TTS }mx) {
      $self->hint_title
         or $self->hint_title( $self->loc( q(handy_hint_title) ) );
      $tip = $self->hint_title.$TTS.$tip;
   }

   $tip =~ s{ \s+ }{ }gmx;

   my $args = { class => q(help tips), title => $tip };

   $self->tiptype eq q(dagger) or return $hacc->span( $args, $field );

   $field .= $hacc->span( $args, $NB );

   return $hacc->span( { class => q(field_group) }, $field );
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

   not $id and $self->ajaxid and $id = $self->id( $self->ajaxid );

   if ($id and not $name) {
      $name = $self->name( $id =~ m{ \. }mx ? (split m{ \. }mx, $id)[1]
                                            : (reverse split m{ _ }mx, $id)[0]);
   }

   not $id and $name and $id = $self->id( $name );

   # We can get the widget type from the config file
   if (not $type and $id and exists $args->{fields}) {
      my $fields = $args->{fields};

      exists $fields->{ $id } and exists $fields->{ $id }->{type}
         and $type = $self->type( $fields->{ $id }->{type} );
   }

   # This is the default widget type if not overidden in the config
   $type or $type = $self->type( q(textfield) );

   $self->name    ( $type             ) unless ($name);
   $self->fields  ( $args->{fields  } );
   $self->messages( $args->{messages} );

   return { qw(ajaxid 1 id 1 name 1 type 1) };
}

sub _ensure_class_loaded {
   my ($self, $class) = @_;

   try        { Class::MOP::load_class( $class ) }
   catch ($e) { $self->_set_error( $e ); return 0 }

   if (Class::MOP::is_class_loaded( $class )) {
      bless $self, $class;
      return 1;
   }

   $self->_set_error( "Class $class loaded but package undefined" );
   return 0;
}

sub _init {
   my ($self, $skip, $args) = @_;

   $self->optional_js ( $args->{optional_js} || [] );
   $self->init        ( $args ); # Allow subclass to set it's own defaults
   $self->_init_fields( $skip, $args->{fields} );
   $self->_init_args  ( $skip, $args );
   $self->_init_event_handler;   # Set the default JS event handler

   my $content_type = $self->content_type;

   $self->is_xml( $content_type =~ m{ / (.*) xml \z }mx ? 1 : 0 );

   # Now we can create HTML elements like we could with CGI.pm
   $self->hacc or
      $self->hacc( HTML::Accessors->new( { content_type => $content_type } ) );

   # Create a Text::Markdown object for use by the msg method
   $self->text_obj( Text::Markdown->new
                    ( empty_element_suffix => $self->is_xml ? q( />) : q(>),
                      tab_width            => $self->tabstop ) );

   # Calculate the prompt width
   my $pwidth = $self->pwidth;

   if ($pwidth and $pwidth =~ m{ \A \d+ \z }mx) {
      $self->pwidth( (int $pwidth * $self->swidth / 100).q(px) );
   }

   my $sep = $self->sep;

   $sep = '&#160;:&#160;' if (not defined $sep and $self->prompt);
   $sep = $self->space    if (    defined $sep and $sep eq q(space));

   $self->sep( $sep );

   my $stepno = $self->stepno;

   $stepno = $self->space if (defined $stepno and $stepno == 0);
   $stepno = $stepno.q(.) if ($stepno and $stepno ne $self->space);

   $self->stepno( $stepno );
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

sub _init_event_handler {
   my $self = shift; my $ajaxid = $self->ajaxid or return;

   # Install default JavaScript event handler
   unless ($self->onblur or $self->onchange or $self->onkeypress) {
      my $method = $self->js_obj.'.server.checkField';

      $self->onblur( $method.'( "'.$ajaxid.'", this.value )' );
   }

   return;
}

sub _init_fields {
   my ($self, $skip, $fields) = @_; my $id = $self->id; my $val;

   if ($id and $fields and exists $fields->{ $id }) {
      my $field = $fields->{ $id };

      for (grep { not $skip->{ $_ } } keys %{ $field }) {
         if (exists $self->{ $_ } and defined ($val = $field->{ $_ })) {
            $self->{ $_ } = $val;
         }
      }
   }

   return;
}

sub _js_config {
   my ($self, $element, $id, $config) = @_; my $list = $NUL;

   ($element and $id and $config) or return $NUL;
   ref $config eq q(HASH) or return $NUL;

   while (my ($k, $v) = each %{ $config }) {
      $list and $list .= ', '; $list .= $k.': '.$v;
   }

   my $text  = $self->js_obj.'.state.config.'.$element.'[ "';
      $text .= $id.'" ] = { '.$list.' };';

   return $self->_wrap_script( $text );
}

sub _render {
   my $self = shift; my $args = {}; my $id = $self->id; my $name = $self->name;

   $id               and $args->{id        } = $id;
   $name             and $args->{name      } = $name;
   $self->required   and $args->{class     } = q( required);
   $self->default    and $args->{default   } = $self->default;
   $self->onblur     and $args->{onblur    } = $self->onblur;
   $self->onkeypress and $args->{onkeypress} = $self->onkeypress;

   return $self->render_field( $args );
}

sub _set_error {
   my ($self, $error) = @_; return $self->text( $error );
}

sub _wrap_script {
   my ($self, $code) = @_;

   return $self->hacc->script( { type => q(text/javascript) },
                               q(//<![CDATA[)."\n".$code."\n".q(//]]>) );
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets - Create HTML form markup

=head1 Version

0.6.$Rev$

=head1 Synopsis

   package CatalystX::Usul::View;

   use parent qw(Catalyst::View CatalystX::Usul);
   use HTML::FormWidgets;

   sub build_widgets {
      my ($self, $c, $sources, $config) = @_; my $s = $c->stash; my $data = [];

      $sources ||= []; $config ||= {};

      for my $part (map { $s->{ $_ } } grep { $s->{ $_ } } @{ $sources }) {
         if (ref $part eq q(ARRAY) and $part->[ 0 ]) {
            push @{ $data }, $_ for (@{ $part });
         }
         else { push @{ $data }, $part }
      }

      $config->{assets      } = $s->{assets};
      $config->{base        } = $c->req->base;
      $config->{content_type} = $s->{content_type};
      $config->{fields      } = $s->{fields} || {};
      $config->{form        } = $s->{form};
      $config->{hide        } = $s->{hidden}->{items};
      $config->{messages    } = $s->{messages};
      $config->{pwidth      } = $s->{pwidth};
      $config->{root        } = $c->config->{root};
      $config->{static      } = $s->{static};
      $config->{swidth      } = $s->{width} if ($s->{width});
      $config->{template_dir} = $c->config->{template_dir};
      $config->{url         } = $c->req->path;

      HTML::FormWidgets->build( $config, $data );
      return $data;
   }

=head1 Description

Transforms a Perl data structure which defines one or more "widgets"
into HTML or XHTML. Each widget is comprised of these optional
components: a line or question number, a prompt string, a separator,
an input field, additional field help, and Ajax field error string.

Input fields are selected by the widget I<type> attribute. A factory
subclass implements the method that generates the HTML or XHTML for
that input field type. Adding more widget types is straightforward

This module is using the L<MooTools|http://mootools.net/> Javascript
library to modify default browser behaviour

This module is used by L<CatalystX::Usul::View> and as such its
main use is as a form generator within a L<Catalyst> application

=head1 Subroutines/Methods

=head2 build

      $class->build( $config, $data );

The L</build> method iterates over a data structure that represents the
form. One or more lists of widget definitions are processed in
turn. New widgets are created and their rendered output replaces their
definitions in the data structure

=head2 new

   $widget = $class->new( [{] key1 => value1, ... [}] );

Construct a widget. Mostly this is called by the L</build> method. It
requires the factory subclass for the widget type.

This method takes a large number of options with each widget using
only few of them. Each option is described in the factory subclasses
which use that option

=head2 inflate

   $widget->inflate( $args );

Creates L<new|HTML::FormWidgets/new> objects and returns their rendered output.
Called by the L</_render> methods in the factory subclasses to inflate
embeded widget definitions

=head2 init

   $widget->init( $args );

Initialises this object with data from the passed arguments. This is
usually overridden in the factory subclass which sets the default for
it's own attributes and then calls this method in the base class

=head2 loc

=head2 localize

   $message_text = $widget->localize( $message_id, @args );

Use the supplied key to return a value from the I<messages>
hash. This hash was passed to the constructor and should contain any
literal text used by any of the widgets

=head2 render

   $html = $widget->render;

Assemble the components of the generated widget. Each component is
concatenated onto a scalar which is the returned value. This method
calls L</_render> which should be defined in the factory subclass for
this widget type.

This method uses these attributes:

=over 3

=item clear

If set to B<left> the widget begins with an C<< <br> >> element

=item stepno

If true it's value is wrapped in a C<< <span class="lineNumber"> >>
element and appended to the return value

=item prompt

If true it's value is wrapped in a C<< <label class="prompt"> >>
element and appended to the return value. The I<id> attribute is used
to set the I<for> attribute of the C<< <label> >> element.  The
I<palign> attribute sets the text align style for the C<< <label> >>
element. The I<nowrap> attribute sets whitespace style to B<nowrap> in
the C<< <label> >> element. The I<pwidth> attribute sets the width style
attribute in the C<< <label> >> element

=item sep

If true it's value is wrapped in a C<< <span class="separator"> >>
element and appended to the return value

=item container

If true the value return by the L</_render> method is wrapped in
C<< <span class="container"> >> element. The value of the I<align>
attribute is added to the space separated class list

=item tip

The text of the field help. If I<tiptype> is set to B<dagger>
(which is the default) then a dagger symbol is
wrapped in a C<< <span class="help tips"> >> and this is appended to the
returned input field. The tip text is used as the I<title>
attribute. If the I<tiptype> is not set to B<dagger> then the help
text is wrapped around the input field itself

=item ajaxid

The text of the message which is displayed if the field's value fails
server side validation

=back

=head2 _bootstrap

   $widget->_bootstrap( $args );

Determine the I<id>, I<name> and I<type> attributes of the widget from
the supplied arguments

=head2 _ensure_class_loaded

   $widget->_ensure_class_loaded( $class );

Once the factory subclass is known this method ensures that it is loaded
and then re-blesses the self referential object into the correct class

=head2 _render

   $html = $widget->_render( $args );

This should have been overridden in the factory subclass. If it gets
called its probably an error so return the value of the I<text>
attribute if set or an error message otherwise

=head2 _set_error

   $widget->_set_error( $error_text );

Stores the passed error message in the I<text> attribute so that it
gets rendered in place of the widget

=head2 __arg_list

   $args = __arg_list( @rest );

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

=head2 __group_fields

   $html = __group_fields( $hacc, $item, $stack );

Wraps the top I<nitems> number of widgets on the build stack in a C<<
<fieldset> >> element with a legend

=head2 __merge_hashes

   $widget = $class->new( __merge_hashes( $config, $item ) );

Does a simple merging of the two hash refs that are passed as
arguments. The second argument takes precedence over the first

=head1 Configuration and Environment

The following are passed to L</build> in the I<config> hash (they
reflect this modules primary use within a L<Catalyst> application):

=over 3

=item assets

Some of the widgets require image files. This attribute is used to
create the URI for those images

=item base

This is the prefix for our URI

=item content_type

Either B<application/xhtml+xml> which generates XHTML 1.1 or
B<text/html> which generates HTML 4.01 and is the default

=item fields

This hash ref contains the fields definitions. Static parameters for
each widget can be stored in configuration files. This reduces the
number of attributes that have to be passed in the call to the
constructor

=item form

Used by the L</Chooser> subclass

=item hide

So that the L</File> and L</Table> subclasses can store the number
of rows added as the hidden form attribute I<nRows>

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

The path to template files used by the L</Template> subclass

=item url

Only used by the L</Tree> subclass to create self referential URIs

=back

Sensible defaults are provided by C<new> if any of the above are undefined

=head1 Factory Subclasses

These are the possible values for the I<type> attribute which defaults
to B<textfield>. Each subclass implements the L</_render> method, it
receives a hash ref of options an returns a scalar containing some
XHTML.

The distribution ships with the following factory subclasses:

=head2 Anchor

Returns an C<< <anchor> >> element with a class set from the I<class>
arg (which defaults to B<linkFade>). It's I<href> attribute
set to the I<href> arg. The anchor body is set to the I<text>
arg

=head2 Button

Generates an image button where I<name> identifies the image
file in I<assets> and is also used as the return value. The
button name is set to I<_verb>. If the image file does not
exist a regular input button is rendered instead

=head2 Checkbox

Return a C<< <checkbox> >> element of value I<value>. Use the
element's value as key to the I<labels> hash. The hash value
(which defaults null) is used as the displayed label. The
I<checked> arg determines the checkbox's initial
setting

=head2 Chooser

Creates a popup window which allows one item to be selected from a
long list of items

=head2 Cloud

Creates list of links from the data set supplied in the I<data> arg

=head2 Date

Return another C<< <textfield> >>, this time with a calendar icon
which when clicked pops up a Javascript date picker. Requires the
appropriate JS library to have been loaded by the page. Attribute
I<width> controls the size of the C<< <textfield> >> (default 10
characters) and I<format> defaults to B<dd/mm/yyyy>. Setting the
I<readonly> attribute to true (which is the default) causes the input
C<< <textfield> >> to become readonly

=head2 File

Display the contents of a file pointed to by I<path>. Supports the
following subtypes:

=over 3

=item csv

Return a table containing the CSV formatted file. This and the I<file>
subtype are selectable if I<select> >= 0 and represents the
column number of the key field

=item file

Default subtype. Like the logfile subtype but without the C<< <pre> >> tags

=item html

The L</_render> method returns an C<< <iframe> >> element whose I<src>
attribute is set to I<path>. Paths that begin with B<root> will have
that replaced with the I<base> attribute value. Paths that do not
begin with "http:" will have the I<base> attribute value prepended to
them

=item logfile

The L</_render> method returns a table where each line of the logfile
appears as a separate row containing one cell. The logfile lines are
each wrapped in C<< <pre> >> tags

=item source

The module L<Syntax::Highlight::Perl> is used to provide colour
highlights for the Perl source code. Tabs are expanded to
I<tabstop> spaces and the result is returned wrapped in
C<< <pre> >> tags

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

=head2 Image

Generates an image tag. The I<text> attribute contains the source URI. The
I<fhelp> attribute contains the alt text and the I<tiptype> attribute is
defaulted to B<normal> (wraps the image in a span with a JS tooltip)

=head2 Label

Calls L</localize> with the I<name> attribute as the message key. If
the message does not exist the value of the I<text> attribute is
used. If I<dropcap> is true the first character of the text is wrapped
in a C<< <span class="dropcap"> >>

=head2 Menu

Generates an unordered list of links. Used with some applied CSS to
implement a navigation menu

=head2 Note

Calls L</localize> with the I<name> attribute as the message key. If
the message does not exist the value if the I<text> attribute is
used. The text is wrapped in a c<< <span class="note"> >> with I<align>
setting the style text alignment and I<width> setting the style width

=head2 POD

Uses L<Pod::Html> to render the POD in the given module as HTML

=head2 Paragraphs

Newspaper like paragraphs rendered in a given number of columns, each
approximately the same length. Defines these attributes;

=over 3

=item column_class

CSS class name of the C<< <span> >> wrapped around each column. Defaults
to null

=item columns

Number of columns to render the paragraphs in. Defaults to 1

=item data

Paragraphs of text. A hash ref whose I<values> attribute is an array
ref. The values of that array are the hash refs that define each
paragraph. The keys of the paragraph hash ref are I<class>, I<heading>, and
I<text>.

=item hclass

Each paragraph can have a heading. This is the class of then C<<
<span> >> that wraps the heading text. Defaults to null

=item max_width

Maximum width of all paragraphs expressed as a percentage. Defaults
to 90

=item para_lead

Paragraph leading. This value is in characters. It is added to the size of
each paragraph to account for the leading applied by the CSS to each
paragraph. If a paragraph is split, then the first part must by greater
than twice this value or the widows and orphans trap will reap it

=back

=head2 Password

Returns a password field of width I<width> which defaults to
twenty characters. If I<subtype> equals B<verify> then the
message B<vPasswordPrompt> and another password field are
appended. The fields I<id> and I<name> are expected
to contain the digit 1 which will be substituted for the digit 2 in
the attributes of the second field

=head2 PopupMenu

Returns a list of C<< <option> >> elements wrapped in a C<< <select> >>
element. The list of options is passed in I<values> with the
display labels in I<labels>. The onchange event handler will
be set to the I<onchange> attribute value

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

=head2 Slider

Implements a dragable slider which returns an integer value. The L</Slider>
widget defines these attributes:

=over 3

=item display

Boolean which if true causes the widget to display a readonly text
field containing the sliders current value. If false a C< <hidden> >>
element is generated instead. Defaults to B<1>

=item element

Name of the Javascript instance variable. This will need setting to a
unique value for each slider on the same form. Defaults to
B<behaviour.sliderElement>

=item hide

If the I<display> attribute is false the current value is pushed onto
this array. Defaults to B<[]>

=item js_obj

This is the callback method for the sliders I<onchange> event
handler. It is passed the slider I<name> and current
I<value>. Defaults to B<behaviour.submit.setField>

=item mode

Which orientation to render in. Defaults to B<horizontal>

=item offset

Sets the minimum value for the slider. Defaults to B<0>

=item range

The range is either the offset plus the number of steps or the two
values of this array if it is set. Defaults to B<false>

=item snap

Snap to the nearest step value? Defaults to B<1>

=item steps

Sets the number of steps. Defaults to B<100>

=item wheel

Use the mouse wheel? Defaults to B<1>

=back

=head2 Table

The input data is in I<< $data->{values} >> which is an array
ref for which each element is an array ref containing the list of
field values.

=head2 Template

Look in I<templatedir> for a L<Template::Toolkit> template
called I<id> with a B<.tt> extension. Slurp it in and return
it as the content for this widget. This provides for a "user defined"
widget type

=head2 Textarea

A text area. It defaults to five lines high (I<height>) and
sixty characters wide (I<width>)

=head2 Textfield

This is the default widget type. Your basic text field which defaults
to sixty characters wide (I<width>)

=head2 Tree

Implements an expanding tree of selectable objects

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=item L<Class::Inspector>

=item L<Class::MOP>

=item L<HTML::Accessors>

=item L<Syntax::Highlight::Perl>

=item L<Text::Markdown>

=item L<Text::ParseWords>

=item L<Text::Tabs>

=item L<TryCatch>

=back

Included in the distribution are the Javascript files whose methods
are called by the event handlers associated with these widgets

=head2 05htmlparser.js

   HTML Parser By John Resig (ejohn.org)
   Original code by Erik Arvidsson, Mozilla Public License
   http://erik.eae.net/simplehtmlparser/simplehtmlparser.js

Used to reimplement "innerHTML" assignments from XHTML

=head2 10mootools.js

   Mootools - My Object Oriented javascript.
   License: MIT-style license.
   WWW: http://mootools.net/

This is the main JS library used with this package

=head2 15html-formwidgets.js

Replaces Mootools' C<setHTML> method with one that uses the HTML
parser. The included copy has a few hacks that improve the Accordion
widget

=head2 50calendar.js

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

The installation script does nothing with the Javascript or PNG files
which are included in the distribution for completeness

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2010 Peter Flanigan. All rights reserved

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

