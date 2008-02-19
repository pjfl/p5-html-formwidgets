package HTML::FormWidgets;

# @(#)$Id$

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use English qw(-no_match_vars);
use File::Spec::Functions;
use Readonly;

use HTML::Accessors;

use version; our $VERSION = qv( sprintf '0.1.%d', q$Rev$ =~ /\d+/gmx );

Readonly my $NUL   => q();
Readonly my $TTS   => q( ~ );
Readonly my %ATTRS =>
   ( ajaxid     => undef,        ajaxtext   => undef,
     align      => q(left),      all        => [],
     assets     => $NUL,         atitle     => 'All',
     base       => $NUL,         behaviour  => q(classic),
     button     => $NUL,         checked    => 0,
     class      => $NUL,         clear      => $NUL,
     columns    => undef,        container  => undef,
     ctitle     => 'Current',    current    => [],
     data       => {},           default    => undef,
     dropcap    => 0,            edit       => 0,
     elem       => undef,        evnt_hndlr => 'checkObj.CheckField',
     field      => $NUL,         fields     => {},
     form       => {},           'format'   => undef,
     fhelp      => $NUL,         header     => undef,
     height     => undef,        hide       => [],
     hint_title => 'Handy Hint', href       => undef,
     id         => undef,        id2key     => {},
     key        => $NUL,         key2id     => {},
     key2url    => {},           labels     => undef,
     max_length => undef,        messages   => {},
     name       => $NUL,         nb_symbol  => q(&nbsp;&dagger;),
     node       => undef,        nowrap     => 0,
     npages     => 1,            onblur     => undef,
     onchange   => undef,        onkeypress => undef,
     palign     => undef,        path       => undef,
     prompt     => $NUL,         fields     => {},
     pwidth     => 40,           required   => 0,
     root       => undef,        screen     => 1000,
     select     => $NUL,         sep        => q(&nbsp;:&nbsp;),
     skindir    => undef,        space      => q(&nbsp;) x 3,
     stepno     => undef,        style      => $NUL,
     subtype    => undef,        target     => $NUL,
     text       => $NUL,         tip        => $NUL,
     tiptype    => q(dagger),    title      => $NUL,
     type       => undef,        url        => undef,
     value      => 1,            values     => [],
     where      => {},           width      => undef );

Readonly my @STATIC => (
   qw(atitle align behaviour checked class clear
      container ctitle edit fhelp format height hint_title max_length
      max_value min_length min_value nowrap onchange onkeypress palign
      prompt pwidth required select sep stepno subtype text tip tiptype
      width) );

__PACKAGE__->mk_accessors( keys %ATTRS );

# Class methods

sub build {
   my ($me, $c, $form) = @_; my $s = $c->stash;
   my ($html, $item, $legend, $list, $ref, @tmp, $widget);

   for $list (@{ $form }) {
      @tmp = ();

      next unless ($list && ref $list eq q(HASH));

      for $item (@{ $list->{items} }) {
         if (ref $item->{content} eq q(HASH)) {
            if ($item->{content}->{group}) {
               $html = $NUL;

               for (1 .. $item->{content}->{nitems}) {
                  $ref  = pop @tmp;
                  chomp $ref->{content};
                  $html = $ref->{content}.$html;
               }

               $widget = __PACKAGE__->new();
               $legend = $widget->elem->legend( $item->{content}->{text} );
               $ref = { content => $widget->elem->fieldset( $legend.$html ) };
            }
            elsif ($item->{content}->{widget}) {
               $ref             = $item->{content};
               $ref->{assets  } = $s->{assets};
               $ref->{base    } = $c->req->base;
               $ref->{fields  } = $s->{fields};
               $ref->{form    } = $s->{form};
               $ref->{footer  } = $s->{footer};
               $ref->{hide    } = $s->{iFrame}->{hidden};
               $ref->{messages} = $s->{messages};
               $ref->{npages  } = $c->req->params->{nPages};
               $ref->{root    } = $c->config->{root};
               $ref->{screen  } = $s->{width} if ($s->{width});
               $ref->{skindir } = catdir($s->{skindir}, $s->{skin});
               $ref->{url     } = $c->req->path;

               $widget = __PACKAGE__->new( $ref );
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
   my ($class, $method, $msg_id, $self, $text, @tmp, $val);

   # Start with some hard coded defaults;
   $self = { %ATTRS };

   # Now we can create HTML elements like we could with CGI.pm
   $self->{elem} = HTML::Accessors->new();

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
   eval "require $class;";

   if ($EVAL_ERROR) {
      $self->{text} = $EVAL_ERROR;
      $self->{type} = undef;
   }

   bless $self, $class;

   $self->{nodeId} = q(node_0); # Define accessor by hand to auto increment

   # Pander to lazy filling out of static definitions
   $self->container( $self->type =~ m{ file|label|note }mx ? 0 : 1 )
      unless (defined $self->container);

   if ($self->ajaxid) {
      $msg_id = $self->fields
              ? $self->fields->{ $self->ajaxid }->{validate}
              : $NUL;
      $msg_id = $msg_id->[0] if (ref $msg_id eq q(ARRAY));
      $text   = $msg_id && $self->messages->{ $msg_id }
              ? $self->messages->{ $msg_id }->{text}
              : $NUL;

      $self->ajaxtext( $text )                 if     ($text);
      $self->ajaxtext( 'Invalid field value' ) unless ($self->ajaxtext);

      # Install default JavaScript event handler
      $self->onblur( $self->evnt_hndlr.'(\''.$self->ajaxid.'\', this.value)' )
         unless ($self->onblur || $self->onchange || $self->onkeypress);
   }

   $self->hint_title( $text ) if ($text = $self->messages->{handy_hint_title});

   unless (defined $self->height) {
      $self->height( $self->type eq q(groupMembership) ||
                     $self->type eq q(scrollingList) ? 10 : 5 );
   }

   if ($self->pwidth && ($self->pwidth =~ m{ \A \d+ \z }mx)) {
      $self->pwidth( (int $self->pwidth * $self->screen / 100).q(px) );
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

sub render {
   my $me = shift; my ($htag, $html, $method, $ref, $text, $tip);

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

   return $html unless ($text = $me->_render( $ref ));

   if ($me->container) {
      $text = $htag->div( { class => q(container ).$me->align }, $text );
   }

   if ($tip = $me->tip) {
      $tip  =~ s{ \n }{ }gmx;
      $tip  = $me->hint_title.$TTS.$tip if ($tip !~ m{ $TTS }mx);
      $tip  =~ s{ \s+ }{ }gmx;
      $ref  = { class => q(help tips), title => $tip };

      if ($me->tiptype ne q(dagger)) { $text = $htag->span( $ref, $text ) }
      else { $text .= $htag->span( $ref, $me->nb_symbol ) }

      $text = $htag->div( { class => q(container) }, $text );
   }

   if ($me->ajaxid) {
      $ref   = { class => q(hidden), id => $me->ajaxid.q(_checkField) };
      $text .= $htag->span( $ref, $me->ajaxtext );
      $text  = $htag->div( { class => q(container) }, $text );
   }

   return $html.$text;
}

# Private methods

sub _arg_list {
   my ($me, @rest) = @_;

   return $rest[0] && ref $rest[0] eq q(HASH) ? $rest[0] : { @rest };
}

sub _classfile {
   my ($me, $class) = @_; $class =~ s{ :: }{/}gmx; return $class.q(.pm);
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

0.1.$Revision$

=head1 Synopsis

   use <HTML::FormWidgets>;

=head1 Description

=head1 Subroutines/Methods

=head1 Diagnostics

=head1 Configuration and Environment

=head1 Dependencies

=over 4

=item L<Class::Accessor::Fast>

=item L<HTML::Accessors>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module.

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome.

=head1 Author

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

=head1 License and Copyright

Copyright (c) 2007 RoxSoft Limited. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
