package HTML::FormWidgets;

use 5.01;
use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.21.%d', q$Rev: 12 $ =~ /\d+/gmx );
use parent                  qw( Class::Accessor::Fast );

use Class::Load             qw( is_class_loaded load_class );
use English                 qw( -no_match_vars );
use HTML::Accessors;
use Scalar::Util            qw( blessed );
use Try::Tiny;

my $COLON   = '&#160;:&#160;';
my $LSB     = '[';
my $NB      = '&#160;&#8224;&#160;';
my $NUL     = q();
my $SPACE   = '&#160;' x 3;
my $SPC     = q( );
my $TTS     = ' ~ ';
my $OPTIONS = {
   content_type    => 'text/html',
   hidden          => sub { {} },
   js_object       => 'html_formwidgets',
   language        => 'en',
   l10n            => undef,
   list_key        => 'items',
   literal_js      => sub { [] },
   max_pwidth      => undef,
   ns              => 'default',
   optional_js     => sub { [] },
   pwidth          => 30,
   skip            => sub { return { qw(options 1 id 1 name 1 type 1) } },
   width           => 1000, };
my $ATTRS   = {
   check_field     => undef,       class           => $NUL,
   clear           => $NUL,        container       => 1,
   container_class => 'container', container_id    => undef,
   default         => undef,       frame_class     => $NUL,
   hacc            => undef,       id              => undef,
   name            => undef,       onblur          => undef,
   onchange        => undef,       onkeypress      => undef,
   options         => undef,       pclass          => 'prompt',
   pwidth          => undef,       prompt          => $NUL,
   readonly        => 0,           required        => 0,
   sep             => undef,       stepno          => undef,
   text            => $NUL,        tip             => $NUL,
   tiptype         => 'dagger',    type            => undef, };

__PACKAGE__->mk_accessors( keys %{ $ATTRS } );

# Private functions
my $_arg_list = sub {
   my (@args) = @_; $args[ 0 ] or return {};

   return ref $args[ 0 ] eq 'HASH' ? $args[ 0 ] : { @args };
};

my $_collect_items = sub {
   my ($nitems, $stack) = @_; my $html = $NUL; $nitems or return $NUL;

   for (1 .. $nitems) {
      my $args = pop @{ $stack }; $html = ($args->{content} || $NUL).$html;
   }

   return $html;
};

my $_form_wrapper = sub {
   my ($options, $item, $stack) = @_; my $content = $item->{content};

   my $hacc = $options->{hacc};
   my $html = $_collect_items->( $content->{nitems}, $stack );
   my $attr = $content->{config} // $content->{attrs} // {};

   $item->{content} = "\n".$hacc->form( $attr, "\n".$html );

   return $item;
};

my $_group_fields = sub {
   my ($options, $item, $stack) = @_; my $content = $item->{content}; my $class;

   $class = delete $content->{frame_class} and $item->{class} = $class;

   my $hacc   = $options->{hacc};
   my $legend = $hacc->legend( $content->{text} );
   my $html   = $_collect_items->( $content->{nitems}, $stack );

   $item->{content} = "\n".$hacc->fieldset( "\n".$legend.$html );
   return $item;
};

my $_inject = sub {
   return { %{ $_[ 1 ] }, options => $_[ 0 ] };
};

my $_merge_attributes = sub {
   my ($dest, $src, $attrs) = @_; $attrs ||= [ keys %{ $src } ];

   for (grep { not exists $dest->{ $_ } or not defined $dest->{ $_ } }
            @{ $attrs }) {
      my $v = $src->{ $_ };

      defined $v and ref $v eq 'CODE' and $v = $v->();
      defined $v and $dest->{ $_ } = $v;
   }

   return $dest;
};

my $_build_widget = sub {
   my ($class, $opts, $item, $stack) = @_; $item or return;

   (ref $item and (ref $item->{content} eq 'HASH' or blessed $item->{content}))
      or return $item;

   my $content = $item->{content};

   $content->{form} and return $_form_wrapper->( $opts, $item, $stack );

   if ($content->{group}) {
      $opts->{skip_groups} and return;
      return $_group_fields->( $opts, $item, $stack );
   }

   my $widget = blessed $content   ? $content
              : $content->{widget} ? $class->new( $_inject->( $opts, $content ))
                                   : undef;

   $widget or return $item;
   $widget->frame_class and $item->{class} = $widget->frame_class;
   $item->{content} = $widget->render;
   return $item;
};

# Private object methods
my $_bootstrap = sub { # Bare minimum is fields + id to get a useful widget
   my ($self, $args) = @_;

   for my $attr (grep { exists $args->{ $_ } } qw( id name type )) {
      $self->$attr( $args->{ $attr } );
   }

   # Defaults id from name
   my $id = $self->id; my $name = $self->name; my $type = $self->type;

   if ($id and not $name) {
      $name = $self->name( $id =~ m{ \. }mx ? (split m{ \. }mx, $id)[  1 ]
                                            : (split m{ \_ }mx, $id)[ -1 ] );
   }

   not $id and $name and $id = $self->id( $name ); $args->{options} ||= {};

   # We can get the widget type from the config file
   if (not $type and $id and exists $args->{options}->{fields}) {
      my $fields = $args->{options}->{fields};

      exists $fields->{ $id } and exists $fields->{ $id }->{type}
         and $type = $self->type( $fields->{ $id }->{type} );
   }
   else { $args->{options}->{fields} ||= {} }

   # This is the default widget type if not overidden in the config
   $type or $type = $self->type( 'textfield' );
   $name or $self->name( $type );
   return;
};

my $_build_hacc = sub {
   # Now we can create HTML elements like we could with CGI.pm
   my $self = shift; my $hacc = $self->options->{hacc};

   $hacc or $hacc = HTML::Accessors->new
      ( { content_type => $self->options->{content_type} } );
   return $hacc
};

my $_build_pwidth = sub { # Calculate the prompt width
   my $self   = shift;
   my $opts   = $self->options;
   my $width  = $opts->{width} || 1024;
   my $pwidth = defined $self->pwidth ? $self->pwidth : $opts->{pwidth};

   if ($pwidth and $pwidth =~ m{ \A \d+ \z }mx) {
      $pwidth  = int $pwidth * $width / 100;
      $opts->{max_pwidth} and $pwidth > $opts->{max_pwidth}
         and $pwidth = $opts->{max_pwidth};
      $pwidth .= 'px';
   }

   return $pwidth;
};

my $_build_sep = sub {
   my $self = shift; my $sep = $self->sep;

   not defined $sep and $self->prompt   and $sep = $COLON;
       defined $sep and $sep eq 'space' and $sep = $SPACE;
       defined $sep and $sep eq 'none'  and $sep = $NUL;
   return $sep;
};

my $_init_args = sub {
   my ($self, $args) = @_; my $skip = $self->options->{skip}; my $v;

   for (grep { not $skip->{ $_ } } keys %{ $args }) {
      exists $self->{ $_ } and defined ($v = $args->{ $_ }) and $self->$_( $v );
   }

   return;
};

my $_init_fields = sub {
   my ($self, $args) = @_; my $fields = $args->{options}->{fields}; my $id;

   $fields and $id = $self->id and exists $fields->{ $id }
      and $self->$_init_args( $fields->{ $id } );
   return;
};

my $_init_hint_title = sub {
   $_[ 1 ]->{hint_title} and $_[ 0 ]->hint_title( $_[ 1 ]->{hint_title} );
   return;
};

my $_init_options = sub {
   $_[ 0 ]->options( $_merge_attributes->( $_[ 1 ]->{options}, $OPTIONS ) );
   return;
};

my $_next_step = sub {
   return $_[ 0 ]->options->{iterator}->();
};

my $_render_field = sub {
   my $self = shift; my $id = $self->id; my $args = {};

   $id                and $args->{id        }  = $id;
   $self->name        and $args->{name      }  = $self->name;
   $self->check_field and $args->{class     }  = 'server';
   $self->required    and $args->{class     } .= ' required';
   $self->onblur      and $args->{onblur    }  = $self->onblur;
   $self->onkeypress  and $args->{onkeypress}  = $self->onkeypress;
   $self->readonly    and $args->{readonly  }  = 'readonly';

   defined $self->default and $args->{default}  = $self->default;

   my $html = $self->render_field( $args );
   my $name = $self->options->{name} // $NUL;
   my $ns   = $self->options->{ns  } // $NUL;

   $self->check_field and $self->add_literal_js( 'server', $id, {
      args   => "[ '${id}', '${name}', '${ns}' ]", event => "'blur'",
      method => "'checkField'" } );
   return $html;
};

my $_set_error = sub {
   my ($self, $error) = @_; return $self->text( $error );
};

my $_build_stepno = sub {
   my $self = shift; my $stepno = $self->stepno;

   defined $stepno and ref $stepno eq 'HASH' and return $stepno;
   defined $stepno and $stepno eq 'none'     and return $NUL;
   defined $stepno and $stepno == -1         and $stepno = $self->$_next_step;
   defined $stepno and $stepno == 0          and $stepno = $SPACE;
           $stepno and $stepno ne $SPACE     and $stepno = "${stepno}.";
   return  $stepno;
};

my $_ensure_class_loaded = sub {
   my ($self, $class) = @_; my $error;

   try { load_class( $class ) } catch { $error = $self->$_set_error( $_ ) };

   $error and return;

   is_class_loaded( $class )
      or ( $self->$_set_error
           ( "Class ${class} loaded but package undefined" ) and return );

   return bless $self, $class; # Rebless ourself as subclass
};

my $_init = sub {
   my ($self, $args) = @_;

   $self->$_init_options   ( $args );
   $self->init             ( $args ); # Allow subclass to set it's own defaults
   $self->$_init_fields    ( $args );
   $self->$_init_args      ( $args );
   $self->$_init_hint_title( $args );
   $self->hacc             ( $self->$_build_hacc   );
   $self->pwidth           ( $self->$_build_pwidth );
   $self->sep              ( $self->$_build_sep    );
   $self->stepno           ( $self->$_build_stepno );
   return;
};

# Class methods
sub build {
   my ($class, $options) = @_; $options ||= {}; my $step = 0;

   my $data = delete $options->{data } ||  [];
   my $key  = $options->{list_key    } ||= $OPTIONS->{list_key    };
   my $type = $options->{content_type} ||= $OPTIONS->{content_type};

   $options->{hacc    } ||= HTML::Accessors->new( content_type => $type );
   $options->{iterator} ||= sub { return ++$step };

   for my $list (grep { $_ and ref $_ eq 'HASH' } @{ $data }) {
      ref $list->{ $key } eq 'ARRAY' or next; my @stack = ();

      for my $item (@{ $list->{ $key } }) {
         my $built = $_build_widget->( $class, $options, $item, \@stack );

         $built and push @stack, $built;
      }

      $list->{ $key } = \@stack;
   }

   return $data;
}

sub new {
   my ($self, @args) = @_; my $args = $_arg_list->( @args );

   # Start with some hard coded defaults
   my $new = bless { %{ $ATTRS } }, blessed $self || $self;

   # Set minimum requirements from the supplied args and the defaults
   $new->$_bootstrap( $args );

   # Your basic factory method trick
   my $class = ucfirst $new->type;
      $class = ('+' eq substr $class, 0, 1)
             ? (substr $class, 1) : __PACKAGE__."::${class}";

   $new->$_ensure_class_loaded( $class );
   $new->$_init( $args ); # Complete the initialization

   return $new;
}

# Public object methods
sub add_hidden {
   my ($self, $name, $value) = @_;

   my $key    = $self->options->{list_key} || 'items';
   my $hidden = $self->options->{hidden  } || {}; $hidden->{ $key } ||= [];

   push @{ $hidden->{ $key } }, {
      content => "\n".$self->hacc->input( {
         name => $name, type => 'hidden', value => $value } ) };
   return;
}

sub add_literal_js {
   my ($self, $js_class, $id, $config) = @_; my $list = $NUL;

   ($js_class and $id and $config) or return;

   if (ref $config eq 'HASH') {
      while (my ($k, $v) = each %{ $config }) {
         if ($k) { $list and $list .= ', '; $list .= "${k}: ".($v || 'null') }
      }
   }
   else { $list = $config };

   my $obj = $self->options->{js_object}; $self->options->{literal_js} ||= [];

   push @{ $self->options->{literal_js} },
      "${obj}.config.${js_class}[ '${id}' ] = { ${list} };";
   return;
}

sub add_optional_js {
   my ($self, @args) = @_; $self->options->{optional_js} ||= [];

   push @{ $self->options->{optional_js} }, @args;
   return;
}

sub hint_title {
   return $_[ 0 ]->{hint_title} ||= $_[ 0 ]->loc( 'form_hint_title' );
}

sub inflate {
   my ($self, $args) = @_;

   (defined $args and ref $args eq 'HASH') or return $args;

   return __PACKAGE__->new( $_inject->( $self->options, $args ) )->render;
}

sub init { # Can be overridden in factory subclass
}

sub is_xml {
   return $_[ 0 ]->options->{content_type} =~ m{ / (.*) xml \z }mx ? 1 : 0;
}

sub loc {
   my ($self, $text, @rest) = @_; my $opts = $self->options; my $l10n;

   if (defined ($l10n = $opts->{l10n})) {
      my $args = { language => $opts->{language}, ns => $opts->{ns} };

      return $l10n->( $args, $text, @rest );
   }

   $text or return; $text = $NUL.$text; # Stringify

   # Expand positional parameters of the form [_<n>]
   0 > index $text, $LSB and return $text;

   my @args = $rest[0] && ref $rest[0] eq 'ARRAY' ? @{ $rest[0] } : @rest;

   push @args, map { '[?]' } 0 .. 10;
   $text =~ s{ \[ _ (\d+) \] }{$args[ $1 - 1 ]}gmx;
   return $text;
}

sub render {
   my $self  = shift; $self->type or return $self->text || $NUL;

   my $field = $self->$_render_field or return $NUL; my $lead = $NUL;

   $self->stepno      and $lead .= $self->render_stepno;
   $self->prompt      and $lead .= $self->render_prompt;
   $self->sep         and $lead .= $self->render_separator;
   $self->tip         and $field = $self->render_tip( $field );
   $self->check_field and $field = $self->render_check_field( $field );

   $field = $lead.$field;

   $self->container and $field = $self->render_container( $field );
   $self->clear eq 'left' and $field = $self->hacc->br.$field;
   return "\n${field}";
}

sub render_check_field {
   my ($self, $field) = @_; my $hacc = $self->hacc; my $id = $self->id;

   $field .= $hacc->span( { class => 'hidden', id => "${id}_ajax" } );

   return $hacc->div( { class => 'field_group' }, $field );
}

sub render_container {
   my ($self, $field) = @_; my $args = { class => $self->container_class };

   $self->container_id and $args->{id} = $self->container_id;

   return $self->hacc->div( $args, $field );
}

sub render_field {
   my ($self, $args) = @_; $self->text and return $self->text;

   my $id = $args->{id} || '*unknown id*';

   return $self->$_set_error( "No render_field method for field ${id}" );
}

sub render_prompt {
   my $self = shift; my $args = { class => $self->pclass };

   $self->id and $args->{for} = $self->id and $args->{id} = $self->id.'_label';

   $self->pwidth and $args->{style} .= 'width: '.$self->pwidth.';';

   return $self->hacc->label( $args, $self->prompt );
}

sub render_separator {
   my $self = shift; my $class = 'separator';

   if ($self->sep eq 'break') {
      $class = 'separator_break'; $self->sep( $NUL );
   }

   return $self->hacc->span( { class => $class }, $self->sep );
}

sub render_stepno {
   my $self = shift; my $stepno = $self->stepno;

   ref $stepno eq 'HASH' and return $self->inflate( $stepno );

   return $self->hacc->span( { class => 'step_number' }, $stepno );
}

sub render_tip {
   my ($self, $field) = @_; my $hacc = $self->hacc; my $break = 'EOL';

   (my $tip = $self->tip) =~ s{ \n }{$break}gmx;

   $tip !~ m{ $TTS }mx and $tip = $self->hint_title.$TTS.$tip;
   $tip =~ s{ \s+ }{ }gmx;

   my $args = { class => 'help tips', title => $tip };

   $self->tiptype eq 'dagger' or return $hacc->span( $args, "\n${field}" );

   $field .= $hacc->span( $args, $NB );

   return $hacc->div( { class => 'field_group' }, "\n".$field );
}

1;

__END__

=pod

=head1 Name

HTML::FormWidgets - Create HTML user interface components

=head1 Version

Describes version v0.21.$Rev: 12 $ of L<HTML::FormWidgets>

=head1 Synopsis

   use HTML::FormWidgets;

   my $widget = HTML::FormWidgets->new( id => 'test' );

   print $widget->render;
   # <div class="container">
   # <input value="" name="test" type="text" id="test" class="ifield" size="40">
   # </div>

=head1 Description

Transforms a Perl data structure which defines one or more "widgets"
into HTML or XHTML. Each widget is comprised of these optional
components: a line or question number, a prompt string, a separator,
an input field, additional field help, and Ajax field error string.

Input fields are selected by the widget C<type> attribute. A factory
subclass implements the method that generates the HTML or XHTML for
that input field type. Adding more widget types is straightforward

This module is using the L<MooTools|http://mootools.net/> Javascript
library to modify default browser behaviour

This module is used by L<CatalystX::Usul::View> and as such its
main use is as a form generator within a L<Catalyst> application

=head1 Configuration and Environment

The following are passed to L</build> in the C<config> hash (they
reflect this modules primary use within a L<Catalyst> application):

=over 3

=item C<assets>

Some of the widgets require image files. This attribute is used to
create the URI for those images

=item C<base>

This is the prefix for our URI

=item C<content_type>

Either C<application/xhtml+xml> which generates XHTML 1.1 or
C<text/html> which generates HTML 4.01 and is the default

=item C<fields>

This hash ref contains the fields definitions. Static parameters for
each widget can be stored in configuration files. This reduces the
number of attributes that have to be passed in the call to the
constructor

=item C<hidden>

So that the L</File> and L</Table> subclasses can store the number
of rows added as the hidden form attribute C<nRows>

=item C<js_object>

This is the name of the global Javascript variable that holds
C<config> object. Defaults to C<html_formwidgets>

=item C<root>

The path to the document root for this application

=item C<width>

Width in pixels of the browser window. This is used to calculate the
width of the field prompt. The field prompt needs to be a fixed length
so that the separator colons align vertically

=item C<templatedir>

The path to template files used by the L</Template> subclass

=back

Sensible defaults are provided by C<new> if any of the above are undefined

=head1 Subroutines/Methods

=head2 Public Methods

=head3 build

      HTML::FormWidgets->build( $config_hash );

The L</build> method iterates over a data structure that represents the
form. One or more lists of widget definitions are processed in
turn. New widgets are created and their rendered output replaces their
definitions in the data structure

=head3 new

   $widget = HTML::FormWidgets->new( [{] key1 => value1, ... [}] );

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

Returns true if the content type matches C<xml>

=head3 loc

   $message_text = $widget->loc( $message_id, @args );

Use the supplied key to return a value from the C<l10n> object. This
object was passed to the constructor and should localise the key to
the required language. The C<@args> list contains parameters to substituted
in place of the placeholders which have the form C<[_n]>

=head3 render

   $html = $widget->render;

Assemble the components of the generated widget. Each component is
concatenated onto a scalar which is the returned value. This method
calls L</render_field> which should be defined in the factory subclass for
this widget type.

This method uses these attributes:

=over 3

=item C<clear>

If set to C<left> the widget begins with an C<< <br> >> element

=item C<stepno>

If true it's value is wrapped in a C<< <span class="lineNumber"> >>
element and appended to the return value

=item C<prompt>

If true it's value is wrapped in a C<< <label class="prompt_class"> >>
element and appended to the return value. The prompt class is set by
the C<pclass> attribute. The C<id> attribute is used to set the C<for>
attribute of the C<< <label> >> element.  The C<pwidth> attribute sets
the width style attribute in the C<< <label> >> element

=item C<sep>

If true it's value is wrapped in a C<< <span class="separator"> >>
element and appended to the return value

=item C<container>

If true the value return by the L</_render> method is wrapped in
C<< <span class="container"> >> element

=item C<tip>

The text of the field help. If C<tiptype> is set to C<dagger>
(which is the default) then a dagger symbol is
wrapped in a C<< <span class="help tips"> >> and this is appended to the
returned input field. The tip text is used as the C<title>
attribute. If the C<tiptype> is not set to C<dagger> then the help
text is wrapped around the input field itself

=item C<check_field>

Boolean which if true causes the field to generate server side check field
requests

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

   $widget->$_bootstrap( $args );

Determine the C<id>, C<name> and C<type> attributes of the widget from
the supplied arguments

=head3 _ensure_class_loaded

   $widget->$_ensure_class_loaded( $class );

Once the factory subclass is known this method ensures that it is loaded
and then re-blesses the self referential object into the correct class

=head3 _set_error

   $widget->$_set_error( $error_text );

Stores the passed error message in the C<text> attribute so that it
gets rendered in place of the widget

=head2 Private Subroutines

=head3 _arg_list

   $args = $_arg_list->( @args );

Accepts either a single argument of a hash ref or a list of key/value
pairs. Returns a hash ref in either case.

=head3 _form_wrapper

   $item = $_form_wrapper->( $options, $item, $stack );

Wraps the top C<nitems> number of widgets on the build stack in a C<<
<form> >> element

=head3 _group_fields

   $item = $_group_fields->( $options, $item, $stack );

Wraps the top C<nitems> number of widgets on the build stack in a C<<
<fieldset> >> element with a legend

=head1 Factory Subclasses

These are the possible values for the C<type> attribute which defaults
to C<textfield>. Each subclass implements the L</_render> method, it
receives a hash ref of options an returns a scalar containing some
XHTML.

The distribution ships with the following factory subclasses:

=head2 Anchor

Returns an C<< <anchor> >> element with a class set from the C<class>
argument (which defaults to C<linkFade>). It's C<href> attribute
set to the C<href> argument. The anchor body is set to the C<text>
argument

=head2 Async

Returns a C<< <div> >> element with a class set from the C<class>
argument (which defaults to C<server>). The div body is set to the
C<text> argument. When the JavaScript C<onload> event handler fires it
will asynchronously load the content of the div if it is visible

=head2 Button

Generates an image button where C<name> identifies the image
file in C<assets> and is also used as the return value. The
button name is set to C<_verb>. If the image file does not
exist a regular input button is rendered instead

=head2 Checkbox

Return a C<< <checkbox> >> element of value C<value>. Use the
element's value as key to the C<labels> hash. The hash value
(which defaults null) is used as the displayed label. The
C<checked> argument determines the checkbox's initial
setting

=head2 Chooser

Creates a popup window which allows one item to be selected from a
long list of items

=head2 Cloud

Creates list of links from the data set supplied in the C<data> argument

=head2 Date

Return another C<< <textfield> >>, this time with a calendar icon
which when clicked pops up a Javascript date picker. Requires the
appropriate JavaScript library to have been loaded by the page. Attribute
C<width> controls the size of the C<< <textfield> >> (default 10
characters) and C<format> defaults to C<dd/mm/yyyy>. Setting the
C<readonly> attribute to true (which is the default) causes the input
C<< <textfield> >> to become read only

=head2 File

Display the contents of a file pointed to by C<path>. Supports the
following subtypes:

=over 3

=item C<csv>

Return a table containing the CSV formatted file. This and the C<file>
subtype are selectable if C<select> >= 0 and represents the
column number of the key field

=item C<file>

Default subtype. Like the logfile subtype but without the C<< <pre> >> tags

=item C<html>

The L</_render> method returns an C<< <iframe> >> element whose C<src>
attribute is set to C<path>. Paths that begin with C<root> will have
that replaced with the C<base> attribute value. Paths that do not
begin with C<http:> will have the C<base> attribute value prepended to
them

=item C<logfile>

The L</_render> method returns a table where each line of the logfile
appears as a separate row containing one cell. The logfile lines are
each wrapped in C<< <pre> >> tags

=item C<source>

The module L<Syntax::Highlight::Perl> is used to provide colour
highlights for the Perl source code. Tabs are expanded to
C<tabstop> spaces and the result is returned wrapped in
C<< <pre> >> tags

=back

=head2 Freelist

New values entered into a text field can be added to the
list. Existing list values (passed in C<values>) can be
removed. The height of the list is set by C<height>.

=head2 GroupMembership

Displays two lists which allow for membership of a group. The first
scrolling list contains "all" values (C<all>), the second
contains those values currently selected (C<current>). The
height of the scrolling lists is set by C<height>

=head2 Hidden

Generates a hidden input field. Uses the C<default> attribute as the value

=head2 Image

Generates an image tag. The C<text> attribute contains the source URI. The
C<fhelp> attribute contains the alt text and the C<tiptype> attribute is
defaulted to C<normal> (wraps the image in a span with a JavaScript tooltip)

=head2 Label

Calls L</loc> with the C<text> attribute if set otherwise returns nothing.
If C<dropcap> is true the first character of the text is wrapped
in a C<< <span class="dropcap"> >>. Wraps the text in a span of class
C<class> which defaults to C<label_text>

=head2 List

Generates an ordered and unordered lists of items. Set the C<ordered>
attribute to true for an ordered list. Defaults to false

=head2 Menu

Generates an unordered list of links. Used with some applied CSS to
implement a navigation menu

=head2 Note

Calls L</localize> with the C<name> attribute as the message key. If
the message does not exist the value if the C<text> attribute is
used. The text is wrapped in a c<< <span class="note"> >> with
C<width> setting the style width

=head2 POD

Uses L<Pod::Html> to render the POD in the given module as HTML

=head2 Paragraphs

Newspaper like paragraphs rendered in a given number of columns, each
approximately the same length. Defines these attributes;

=over 3

=item C<column_class>

CSS class name of the C<< <span> >> wrapped around each column. Defaults
to null

=item C<columns>

Number of columns to render the paragraphs in. Defaults to 1

=item C<data>

Paragraphs of text. A hash ref whose C<values> attribute is an array
ref. The values of that array are the hash refs that define each
paragraph. The keys of the paragraph hash ref are C<class>, C<heading>, and
C<text>.

=item C<hclass>

Each paragraph can have a heading. This is the class of the C<<
<div> >> that wraps the heading text. Defaults to null

=item C<max_width>

Maximum width of all paragraphs expressed as a percentage. Defaults
to 90

=item C<para_lead>

Paragraph leading. This value is in characters. It is added to the size of
each paragraph to account for the leading applied by the CSS to each
paragraph. If a paragraph is split, then the first part must by greater
than twice this value or the widows and orphans trap will reap it

=back

=head2 Password

Returns a password field of width C<width> which defaults to
twenty characters. If C<subtype> equals C<verify> then the
message C<vPasswordPrompt> and another password field are
appended. The fields C<id> and C<name> are expected
to contain the digit 1 which will be substituted for the digit 2 in
the attributes of the second field

=head2 PopupMenu

Returns a list of C<< <option> >> elements wrapped in a C<< <select> >>
element. The list of options is passed in C<values> with the
display labels in C<labels>. The C<onchange> event handler will
be set to the C<onchange> attribute value

=head2 RadioGroup

The attribute C<columns> sets the number of columns for the
returned table of radio buttons. The list of button values is passed in
C<values> with the display labels in C<labels>. The
C<onchange> event handler will be set to C<onchange>

=head2 Rule

Generates a horizontal rule with optional clickable action

=head2 ScrollPin

Implements clickable navigation markers that scroll the page to given
location. Returns an unordered list of class C<class> which defaults
to C<pintray>. This is the default selector class for the JavaScript
C<ScrollPins> object

=head2 ScrollingList

The C<height> attribute controls the number of options the scrolling
list displays.  The list of options is passed in C<values> with the
display labels in C<labels>. The C<onchange> event handler will
be set to C<onchange>

=head2 SidebarPanel

Generates the markup for a sidebar accordion panel (a "header" C<div>
and a "body" C<div>). The panel contents are requested asynchronously
by the browser. The L</SidebarPanel> widget defines these attributes:

=over 3

=item C<config>

A hash ref whose keys and values are written out as literal JavaScript by
L</add_literal_js>

=item C<header>

A hash that provides the C<id>, C<class>, and C<text> for header C<div>

=item C<panel>

A hash that provides the C<id> and C<class> for body C<div>

=back

=head2 Slider

Implements a dragable slider which returns an integer value. The L</Slider>
widget defines these attributes:

=over 3

=item C<display>

Boolean which if true causes the widget to display a read only text
field containing the sliders current value. If false a C< <hidden> >>
element is generated instead. Defaults to C<1>

=item C<element>

Name of the Javascript instance variable. This will need setting to a
unique value for each slider on the same form. Defaults to
C<behaviour.sliderElement>

=item C<hide>

If the C<display> attribute is false the current value is pushed onto
this array. Defaults to C<[]>

=item C<mode>

Which orientation to render in. Defaults to C<horizontal>

=item C<offset>

Sets the minimum value for the slider. Defaults to C<0>

=item C<range>

The range is either the offset plus the number of steps or the two
values of this array if it is set. Defaults to C<false>

=item C<snap>

Snap to the nearest step value? Defaults to C<1>

=item C<steps>

Sets the number of steps. Defaults to C<100>

=item C<wheel>

Use the mouse wheel? Defaults to C<1>

=back

=head2 TabSwapper

A list of C<div>s is constructed that can be styled to display only one at
a time. Clicking the tab header displays the corresponding C<div>

=head2 Table

The input data is in C<< $data->{values} >> which is an array
ref for which each element is an array ref containing the list of
field values.

=head2 TableRow

Returns markup for a table row. Used to generate responses for the C<LiveGrid>
JavaScript class

=head2 Template

Look in C<templatedir> for a L<Template::Toolkit> template
called C<id> with a F<.tt> extension. Slurp it in and return
it as the content for this widget. This provides for a "user defined"
widget type

=head2 Textarea

A text area. It defaults to five lines high (C<height>) and
sixty characters wide (C<width>)

=head2 Textfield

This is the default widget type. Your basic text field which defaults
to sixty characters wide (C<width>)

=head2 Tree

Implements an expanding tree of selectable objects

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<Class::Accessor::Fast>

=item L<Class::Load>

=item L<HTML::Accessors>

=item L<Syntax::Highlight::Perl>

=item L<Text::ParseWords>

=item L<Text::Tabs>

=item L<Try::Tiny>

=back

Included in the distribution are the Javascript files whose methods
are called by the event handlers associated with these widgets

=head2 F<05htmlparser.js>

   HTML Parser By John Resig (ejohn.org)
   Original code by Erik Arvidsson, Mozilla Public License
   http://erik.eae.net/simplehtmlparser/simplehtmlparser.js

Used to reimplement C<innerHTML> assignments from XHTML

=head2 F<10mootools.js>

   Mootools - My Object Oriented javascript.
   License: MIT-style license.
   WWW: http://mootools.net/

This is the main JavaScript library used with this package

=head2 F<15html-formwidgets.js>

Replaces Mootools' C<setHTML> method with one that uses the HTML
parser. The included copy has a few hacks that improve the Accordion
widget

=head2 F<50calendar.js>

   Copyright Mihai Bazon, 2002-2005  |  www.bazon.net/mishoo
   The DHTML Calendar, version 1.0   |  www.dynarch.com/projects/calendar
   License: GNU Lesser General Public License

Implements the calendar popup used by the C<::Date> subclass

=head2 F<behaviour.js>

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

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2014 Peter Flanigan. All rights reserved

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
