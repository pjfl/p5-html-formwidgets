# @(#)$Id$

package HTML::FormWidgets;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.7.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(Class::Accessor::Fast);

use Class::MOP;
use English qw(-no_match_vars);
use HTML::Accessors;
use Scalar::Util qw(blessed);
use Try::Tiny;

my $LSB   = q([);
my $NB    = '&#160;&#8224;';
my $COLON = '&#160;:&#160;';
my $NUL   = q();
my $SPACE = '&#160;' x 3;
my $SPC   = q( );
my $TTS   = q( ~ );
my $ATTRS = {
   globals         => {
      content_type => q(text/html),
      hide         => [],
      js_object    => q(html_formwidgets),
      literal_js   => [],
      optional_js  => [],
      pwidth       => 30,
      skip         => { qw(ajaxid 1 globals 1 id 1 name 1 type 1) },
      swidth       => 1000, },
   ajaxid          => undef,        class           => $NUL,
   clear           => $NUL,         container       => 1,
   container_class => q(container), container_id    => undef,
   default         => undef,        frame_class     => $NUL,
   hacc            => undef,        hint_title      => $NUL,
   id              => undef,        name            => undef,
   onblur          => undef,        onchange        => undef,
   onkeypress      => undef,        pclass          => q(prompt),
   pwidth          => undef,        prompt          => $NUL,
   readonly        => 0,            required        => 0,
   sep             => undef,        stepno          => undef,
   text            => $NUL,         tip             => $NUL,
   tiptype         => q(dagger),    type            => undef, };

__PACKAGE__->mk_accessors( keys %{ $ATTRS } );

# Class methods

sub build {
   my ($class, $globals, $data) = @_; $globals ||= {}; $data ||= {};

   my $key  = $globals->{list_key    } || q(items);
   my $type = $globals->{content_type} || $ATTRS->{globals}->{content_type};
   my $step = 0;

   $globals->{hacc    } = HTML::Accessors->new( content_type => $type );
   $globals->{iterator} = sub { return ++$step };

   for my $list (grep { $_ and ref $_ eq q(HASH) } @{ $data }) {
      my @stack = (); ref $list->{ $key } eq q(ARRAY) or next;

      for my $item (@{ $list->{ $key } }) {
         my $built = __build_widget( $class, $globals, $item, \@stack );

         $built and push @stack, $built;
      }

      @{ $list->{ $key } } = @stack;
   }

   return;
}

sub __build_widget {
   my ($class, $globals, $item, $stack) = @_; $item or return;

   (ref $item and ref $item->{content} eq q(HASH)) or return $item;

   if ($item->{content}->{group}) {
      $globals->{skip_groups} and return;

      $item->{content} = __group_fields( $globals->{hacc}, $item, $stack );
      return $item;
   }

   my $widget = blessed $item->{content}
              ? $item->{content}
              : $item->{content}->{widget}
              ? $class->new( __inject( $globals, $item->{content} ) )
              : undef;

   $widget or return $item;
   $widget->frame_class and $item->{class} = $widget->frame_class;
   $item->{content} = $widget->render;
   return $item;
}

sub __group_fields {
   my ($hacc, $item, $stack) = @_; my $html = $NUL; my $class;

   $class = delete $item->{content}->{frame_class} and $item->{class} = $class;

   for (1 .. $item->{content}->{nitems}) {
      my $args = pop @{ $stack }; $html = ($args->{content} || $NUL).$html;
   }

   my $legend = $hacc->legend( $item->{content}->{text} );

   return "\n".$hacc->fieldset( "\n".$legend.$html );
}

sub __inject {
   $_[ 1 ]->{globals} = $_[ 0 ]; return $_[ 1 ];
}

sub new {
   my ($self, @rest) = @_; my $args = __arg_list( @rest );

   # Start with some hard coded defaults;
   my $new = bless { %{ $ATTRS } }, ref $self || $self;

   # Set minimum requirements from the supplied args and the defaults
   $new->_bootstrap( $args );

   # Your basic factory method trick
   my $class = ucfirst $new->type;
      $class = (q(+) eq substr $class, 0, 1)
             ? (substr $class, 1) : __PACKAGE__.q(::).$class;

   $new->_ensure_class_loaded( $class );
   $new->_init( $args ); # Complete the initialization

   return $new;
}

sub __arg_list {
   my (@rest) = @_; $rest[ 0 ] or return {};

   return ref $rest[ 0 ] eq q(HASH) ? $rest[ 0 ] : { @rest };
}

# Public object methods

sub add_hidden {
   my ($self, $name, $value) = @_;

   push @{ $self->globals->{hide} }, {
      content => $self->hacc->input( {
         name => $name, type => q(hidden), value => $value } ) };

   return;
}

sub add_literal_js {
   my ($self, $js_class, $id, $config) = @_; my $list = $NUL;

   ($js_class and $id and $config and ref $config eq q(HASH)) or return;

   while (my ($k, $v) = each %{ $config }) {
      if ($k) { $list and $list .= ', '; $list .= $k.': '.($v || 'null') }
   }

   my $text  = $self->globals->{js_object};
      $text .= ".config.${js_class}[ '${id}' ] = { ${list} };";

   push @{ $self->globals->{literal_js} }, $text;
   return;
}

sub add_optional_js {
   my ($self, @rest) = @_;

   push @{ $self->globals->{optional_js} }, @rest;
   return;
}

sub inflate {
   my ($self, $args) = @_;

   (defined $args and ref $args eq q(HASH)) or return $args;

   return __PACKAGE__->new( __inject( $self->globals, $args ) )->render;
}

sub init {
   # Can be overridden in factory subclass
}

sub is_xml {
   return $_[ 0 ]->globals->{content_type} =~ m{ / (.*) xml \z }mx ? 1 : 0;
}

sub loc {
   my ($self, $text, @rest) = @_; my $l10n = $self->globals->{l10n};

   defined $l10n and return $l10n->( $text, @rest );

   $text or return; $text = $NUL.$text; # Stringify

   # Expand positional parameters of the form [_<n>]
   0 > index $text, $LSB and return $text;

   my @args = $rest[0] && ref $rest[0] eq q(ARRAY) ? @{ $rest[0] } : @rest;

   push @args, map { '[?]' } 0 .. 10;
   $text =~ s{ \[ _ (\d+) \] }{$args[ $1 - 1 ]}gmx;
   return $text;
}

sub render {
   my $self  = shift; $self->type or return $self->text || $NUL;

   my $field = $self->_render_field or return $NUL; my $lead  = "\n";

   $self->clear eq q(left) and $lead .= $self->hacc->br;

   $self->stepno    and $lead .= $self->render_stepno;
   $self->prompt    and $lead .= $self->render_prompt;
   $self->sep       and $lead .= $self->render_separator;
   $self->tip       and $field = $self->render_tip        ( $field );
   $self->ajaxid    and $field = $self->render_check_field( $field );
   $self->container and $field = $self->render_container  ( $field );

   return $lead.$field;
}

sub render_check_field {
   my ($self, $field) = @_; my $hacc = $self->hacc; my $id = $self->ajaxid;

   $field .= $hacc->span( { class => q(hidden), id => $id.q(_ajax) } );

   return $hacc->div( { class => q(field_group) }, $field );
}

sub render_container {
   my ($self, $field) = @_; my $args = { class => $self->container_class };

   $self->container_id and $args->{id} = $self->container_id;

   return $self->hacc->div( $args, $field );
}

sub render_field {
   my ($self, $args) = @_; $self->text and return $self->text;

   my $id = $args->{id} || '*unknown id*';

   return $self->_set_error( "No render_field method for field $id" );
}

sub render_prompt {
   my $self = shift; my $args = { class => $self->pclass };

   $self->id and $args->{for} = $self->id and $args->{id} = $self->id.q(_label);

   $self->pwidth and $args->{style} .= 'width: '.$self->pwidth.q(;);

   return $self->hacc->label( $args, $self->prompt );
}

sub render_separator {
   my $self = shift; my $class = q(separator);

   if ($self->sep eq q(break)) {
      $class = q(separator_break); $self->sep( $SPACE );
   }

   return $self->hacc->span( { class => $class }, $self->sep );
}

sub render_stepno {
   my $self = shift; my $stepno = $self->stepno;

   ref $stepno eq q(HASH) and return $self->inflate( $stepno );

   return $self->hacc->span( { class => q(step_number) }, $stepno );
}

sub render_tip {
   my ($self, $field) = @_; my $hacc = $self->hacc;

   (my $tip = $self->tip) =~ s{ \n }{ }gmx;

   $tip !~ m{ $TTS }mx and $tip = $self->hint_title.$TTS.$tip;
   $tip =~ s{ \s+ }{ }gmx;

   my $args = { class => q(help tips), title => $tip };

   $self->tiptype eq q(dagger) or return $hacc->span( $args, $field );

   $field .= $hacc->span( $args, $NB );

   return $hacc->div( { class => q(field_group) }, $field );
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

   not $id and $name and $id = $self->id( $name ); $args->{globals} ||= {};

   # We can get the widget type from the config file
   if (not $type and $id and exists $args->{globals}->{fields}) {
      my $fields = $args->{globals}->{fields};

      exists $fields->{ $id } and exists $fields->{ $id }->{type}
         and $type = $self->type( $fields->{ $id }->{type} );
   }

   # This is the default widget type if not overidden in the config
   $type or $type = $self->type( q(textfield) );
   $name or $self->name( $type );
   return;
}

sub _build_hacc {
   # Now we can create HTML elements like we could with CGI.pm
   my $self = shift; my $hacc = $self->globals->{hacc};

   $hacc or $hacc = HTML::Accessors->new
      ( { content_type => $self->globals->{content_type} } );

   return $hacc
}

sub _build_hint_title {
   my $self = shift;

   return $self->hint_title || $self->loc( q(form_hint_title) );
}

sub _build_pwidth {
   # Calculate the prompt width
   my $self   = shift;
   my $pwidth = defined $self->pwidth
              ? $self->pwidth : $self->globals->{pwidth};

   $pwidth and $pwidth =~ m{ \A \d+ \z }mx
      and $pwidth = (int $pwidth * $self->globals->{swidth} / 100).q(px);

   return $pwidth;
}

sub _build_sep {
   my $self = shift; my $sep = $self->sep;

   not defined $sep and $self->prompt    and $sep = $COLON;
       defined $sep and $sep eq q(space) and $sep = $SPACE;
       defined $sep and $sep eq q(none)  and $sep = $NUL;

   return $sep;
}

sub _build_stepno {
   my $self = shift; my $stepno = $self->stepno;

   defined $stepno and ref $stepno eq q(HASH) and return $stepno;
   defined $stepno and $stepno eq q(none)     and return $NUL;
   defined $stepno and $stepno == -1          and $stepno = $self->_next_step;
   defined $stepno and $stepno == 0           and $stepno = $SPACE;
           $stepno and $stepno ne $SPACE      and $stepno = $stepno.q(.);

   return $stepno;
}

sub _ensure_class_loaded {
   my ($self, $class) = @_;

   try   { Class::MOP::load_class( $class ) }
   catch { $self->_set_error( $_ ); return 0 };

   if (Class::MOP::is_class_loaded( $class )) {
      bless $self, $class; return 1; # Rebless ourself as subclass
   }

   $self->_set_error( "Class $class loaded but package undefined" );
   return 0;
}

sub _init {
   my ($self, $args) = @_;

   $self->_init_globals( $args );
   $self->init         ( $args ); # Allow subclass to set it's own defaults
   $self->_init_fields ( $args );
   $self->_init_args   ( $args );
   $self->hacc         ( $self->_build_hacc       );
   $self->hint_title   ( $self->_build_hint_title );
   $self->pwidth       ( $self->_build_pwidth     );
   $self->sep          ( $self->_build_sep        );
   $self->stepno       ( $self->_build_stepno     );
   return;
}

sub _init_args {
   my ($self, $args) = @_; my $skip = $self->globals->{skip}; my $v;

   for (grep { not $skip->{ $_ } } keys %{ $args }) {
      exists $self->{ $_ } and defined ($v = $args->{ $_ })
         and $self->{ $_ } = $v;
   }

   return;
}

sub _init_globals {
   my ($self, $args) = @_; my $globals = $args->{globals} || {};

   $self->globals->{ $_ } = $globals->{ $_ } for (keys %{ $globals });

   return;
}

sub _init_fields {
   my ($self, $args) = @_; my $fields = $args->{globals}->{fields}; my $id;

   $fields and $id = $self->id and exists $fields->{ $id }
      and $self->_init_args( $fields->{ $id } );

   return;
}

sub _next_step {
   return $_[ 0 ]->globals->{iterator}->();
}

sub _render_field {
   my $self = shift; my $id = $self->id; my $args = {};

   $id               and $args->{id        }  = $id;
   $self->name       and $args->{name      }  = $self->name;
   $self->ajaxid     and $args->{class     }  = q(server);
   $self->required   and $args->{class     } .= q( required);
   $self->default    and $args->{default   }  = $self->default;
   $self->onblur     and $args->{onblur    }  = $self->onblur;
   $self->onkeypress and $args->{onkeypress}  = $self->onkeypress;
   $self->readonly   and $args->{readonly  }  = q(readonly);

   my $html = $self->render_field( $args );

   $self->ajaxid and $self->add_literal_js( 'server', $id, {
      args => "[ '${id}' ]", event => "'blur'", method => "'checkField'" } );

   return $html;
}

sub _set_error {
   my ($self, $error) = @_; return $self->text( $error );
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets - Create HTML form markup

=head1 Version

0.7.$Rev$

=head1 Synopsis

   use HTML::FormWidgets;

   my $widget = HTML::FormWidgets->new( id => q(test) );

   print $widget->render;
   # <div class="container">
   # <input value="" name="test" type="text" id="test" class="ifield" size="40">
   # </div>

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

=head2 Public Methods

=head3 build

      $class->build( $config, $data );

The L</build> method iterates over a data structure that represents the
form. One or more lists of widget definitions are processed in
turn. New widgets are created and their rendered output replaces their
definitions in the data structure

=head3 new

   $widget = $class->new( [{] key1 => value1, ... [}] );

Construct a widget. Mostly this is called by the L</build> method. It
requires the factory subclass for the widget type.

This method takes a large number of options with each widget using
only few of them. Each option is described in the factory subclasses
which use that option

=head3 add_hidden

   $widget->add_hidden( $key, $value );

The key / value pair are added to list of hidden input elements that will
be included in the page

=head3 add_literal_js

   $widet->add_literal_js( $js_class_name, $id, $config );

The config hash will be serialised and added to the literal Javascript on
the page

=head3 add_optional_js

   $widget->add_optional_js( @filenames );

The list of Javascript filenames (with extension, without path) are added
to the list of files which will be included on the page

=head3 inflate

   $widget->inflate( $args );

Creates L<new|HTML::FormWidgets/new> objects and returns their rendered output.
Called by the L</_render> methods in the factory subclasses to inflate
embeded widget definitions

=head3 init

   $widget->init( $args );

Initialises this object with data from the passed arguments. This is
usually overridden in the factory subclass which sets the default for
it's own attributes. In the base class this method does nothing

=head3 is_xml

   $bool = $widget->is_xml;

Returns true if the content type matches I<xml>

=head3 loc

   $message_text = $widget->loc( $message_id, @args );

Use the supplied key to return a value from the I<l10n> object. This
object was passed to the constructor and should localize the key to
the required language. The C<@args> list contains parameters to substituted
in place of the placeholders which have the form I<[_n]>

=head3 render

   $html = $widget->render;

Assemble the components of the generated widget. Each component is
concatenated onto a scalar which is the returned value. This method
calls L</render_field> which should be defined in the factory subclass for
this widget type.

This method uses these attributes:

=over 3

=item clear

If set to B<left> the widget begins with an C<< <br> >> element

=item stepno

If true it's value is wrapped in a C<< <span class="lineNumber"> >>
element and appended to the return value

=item prompt

If true it's value is wrapped in a C<< <label class="prompt_class"> >>
element and appended to the return value. The prompt class is set by
the C<pclass> attribute. The I<id> attribute is used to set the I<for>
attribute of the C<< <label> >> element.  The I<pwidth> attribute sets
the width style attribute in the C<< <label> >> element

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

=head3 render_check_field

Adds markup for the Ajax field validation

=head3 render_container

Wraps the rendered field in a containing div

=head3 render_field

Should be overridden in the factory subclass. It should return the markup
for the specified field type

=head3 render_prompt

Adds a label element to the generated markup

=head3 render_separator

Insert a spacing element between the prompt and the field

=head3 render_stepno

Markup containing the step number on the form if required

=head3 render_tip

Flyover tooltip field help text

=head2 Private Methods

=head3 _bootstrap

   $widget->_bootstrap( $args );

Determine the I<id>, I<name> and I<type> attributes of the widget from
the supplied arguments

=head3 _ensure_class_loaded

   $widget->_ensure_class_loaded( $class );

Once the factory subclass is known this method ensures that it is loaded
and then re-blesses the self referential object into the correct class

=head3 _set_error

   $widget->_set_error( $error_text );

Stores the passed error message in the I<text> attribute so that it
gets rendered in place of the widget

=head2 Private Subroutines

=head3 __arg_list

   $args = __arg_list( @rest );

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

=head3 __group_fields

   $html = __group_fields( $hacc, $item, $stack );

Wraps the top I<nitems> number of widgets on the build stack in a C<<
<fieldset> >> element with a legend

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

=item js_object

This is the name of the global Javascript variable that holds
B<config> object. Defaults to B<html_formwidgets>

=item root

The path to the document root for this application

=item swidth

Width in pixels of the browser window. This is used to calculate the
width of the field prompt. The field prompt needs to be a fixed length
so that the separator colons align vertically

=item templatedir

The path to template files used by the L</Template> subclass

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

Calls L</loc> with the I<text> attribute if set otherwise returns nothing.
If I<dropcap> is true the first character of the text is wrapped
in a C<< <span class="dropcap"> >>. Wraps the text in a span of class
I<class> which defaults to B<label_text>

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

Each paragraph can have a heading. This is the class of the C<<
<div> >> that wraps the heading text. Defaults to null

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

=head2 ScrollPin

Implements clickable navigation markers that scroll the page to given
location. Returns an unordered list of class I<class> which defaults
to B<pintray>. This is the default selector class for the JS C<ScrollPins>
object

=head2 ScrollingList

The I<height> attribute controls the number of options the scrolling
list displays.  The list of options is passed in I<values> with the
display labels in I<labels>. The onchange event handler will
be set to I<onchange>

=head2 SidebarPanel

Generates the markup for a sidebar accordion panel. The
panel contents are requested asyncronously by the browser. The
L</SidebarPanel> widget defines these attributes:

=over 3

=item config

=item header

=item panel

=back

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

=head2 TabSwapper

A list of I<div>s is constructed that can be styled to display only one at
a time. Clicking the tab header displays the coresponding I<div>

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

=head2 UnorderedList

Generates an unordered list of list items

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=item L<Class::MOP>

=item L<HTML::Accessors>

=item L<Syntax::Highlight::Perl>

=item L<Text::ParseWords>

=item L<Text::Tabs>

=item L<Try::Tiny>

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

Copyright (c) 2011 Peter Flanigan. All rights reserved

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
