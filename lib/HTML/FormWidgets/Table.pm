package HTML::FormWidgets::Table;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.3.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(add_tip assets data edit hide js_obj
                              remove_tip select) );

my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $text  = 'Enter a new item into the adjacent text ';
   $text .= 'fields and then click this button to add ';
   $text .= 'it to the list';
   $text  = $self->loc( q(tableAddTip) ) || $text;
   $self->add_tip(      $self->hint_title.$TTS.$text );
   $self->assets(       q() );
   $self->class(        q(small table) );
   $self->container(    0 );
   $self->data(         { flds => [], values => [] } );
   $self->edit(         0 );
   $self->hide(         [] );
   $self->js_obj(       q(tableObj) );
   $text  = 'Select one or more items from the ';
   $text .= 'above list and then click this button ';
   $text .= 'to remove them';
   $text  = $self->loc( q(tableRemoveTip) ) || $text;
   $self->remove_tip(   $self->hint_title.$TTS.$text );
   $self->select(       q() );
   $self->NEXT::init(   $args );
   return;
}

sub _render {
   my ($self, $args) = @_;
   my ($class, $fld, $fld_val, $r_no, $rows, $text, $text1, $type, $val);

   my $c_no  = 0;
   my $cells = q();
   my $data  = $self->data;
   my $hacc  = $self->hacc;

   if ($self->select eq q(left)) {
      $args           = { class => $self->class };
      $args->{class} .= $self->edit ? q( select) : q( minimal);
      $cells         .= $hacc->th( $args, 'Select' );
   }

   for $fld (@{ $data->{flds} }) {
      $args = { class => $self->class };

      if (exists $data->{hclass}->{ $fld }) {
         next if ($data->{hclass}->{ $fld } eq q(hide));

         $args->{class} .= q( ).$data->{hclass}->{ $fld };
      }

      $args->{class} .= q( nowrap) unless (exists $data->{wrap}->{ $fld });
      $cells         .= $hacc->th( $args, $data->{labels}->{ $fld } );
      $c_no++;
   }

   if ($self->select eq q(right)) {
      $args           = { class => $self->class };
      $args->{class} .= $self->edit ? q( select) : q( minimal);
      $cells         .= $hacc->th( $args, 'Select' );
   }

   $rows = $hacc->tr( $cells ); $r_no = 0;

   for $val (@{ $data->{values} }) {
      $cells = q(); $c_no = 0;

      if ($self->select eq q(left) and $data->{values}->[0]) {
         $cells .= $self->_check_box( $r_no, $c_no, $val->{id} );
      }

      for $fld (@{ $data->{flds} }) {
         if ($self->edit) {
            $args            = {};
            $args->{default} = $val->{ $fld };
            $args->{name}    = $self->name.q(_).$fld.$r_no;
            $cells          .= $self->_editable_cell( $data, $fld, $args );
         }
         else {
            next if ($data->{hclass}->{ $fld }
                     and $data->{hclass}->{ $fld } eq q(hide));

            $args          = {};
            $args->{align} = exists $data->{align}->{ $fld }
                           ? $data->{align}->{ $fld } : q(left);
            $class         = $data->{class} || q(dataValue);

            if (ref $class and exists $class->{ $fld }) {
               $args->{class} = $class->{ $fld };
            }
            else { $args->{class} = $class }

            $args->{class} .= $c_no % 2 == 0 ? q( even) : q( odd);

            unless (exists $data->{wrap}->{ $fld }) {
               $args->{class} .= q( nowrap);
            }

            $fld_val = $self->_inflate( $val->{ $fld } ) || q(&nbsp;);
            $cells  .= $hacc->td( $args, $fld_val )."\n";
         }

         $c_no++;
      }

      if ($self->select eq q(right) and $data->{values}->[0]) {
         $cells .= $self->_check_box( $r_no, $c_no, $val->{id} );
      }

      $class = $data->{class} || q(dataValue);
      $args  = { class => $class, id => $self->name.q(_row).$r_no };
      $rows .= $hacc->tr( $args, $cells ); $r_no++;
   }

   my $content = $self->_inflate( { name    => $self->name.q(_nrows),
                                    default => $r_no,
                                    type    => q(hidden),
                                    widget  => 1 } );
   push @{ $self->hide }, { content => $content };

   if ($self->edit) {
      $cells = q();

      for $c_no (0 .. $#{ $data->{flds} }) {
         $fld          = $data->{flds}->[ $c_no ];
         $args         = { id => $self->name.q(_add).$c_no };
         $args->{name} = $self->name.q(_).$fld;
         $cells       .= $self->_editable_cell( $data, $fld, $args );
      }

      $args             = {};
      $args->{class  }  = $args->{name} = q(button);
      $args->{onclick}  = 'return '.$self->js_obj.".addTableRow('";
      $args->{onclick} .= $self->name."', 1)";
      $args->{src    }  = $self->assets.'add_item.png';
      $args->{value  }  = $self->name.q(_add);
      $text             = $hacc->image_button( $args );
      $args             = { class => q(help tips), title => $self->add_tip };
      $text             = $hacc->span( $args, $text );

      if ($self->select) {
         $args             = {};
         $args->{class  }  = $args->{name} = q(button);
         $args->{onclick}  = 'return '.$self->js_obj;
         $args->{onclick} .= ".removeTableRow('".$self->name."')";
         $args->{src    }  = $self->assets.'remove_item.png';
         $args->{value  }  = $self->name.q(_remove);
         $text1            = $hacc->image_button( $args );
         $args             = { class => q(help tips),
                               title => $self->remove_tip };
         $text            .= $hacc->span( $args, $text1 );
      }

      $class  = $data->{class} || q(dataValue);
      $cells .= $hacc->td( $text );
      $rows  .= $hacc->tr( { class => $class,
                             id    => $self->name.q(_add) }, $cells );
   }

   return $hacc->table( { class => ($self->prompt ? q(form) : q(std)) },
                        $rows );
}

# Private methods

sub _editable_cell {
   my ($self, $data, $fld, $args) = @_;

   if (exists $data->{maxlengths}->{ $fld }) {
      $args->{maxlength} = $data->{maxlengths}->{ $fld };
   }

   my $type = $data->{typelist}->{ $fld } || q(textfield);

   if ($type eq q(textarea)) {
      $args->{rows} = exists $data->{rows}->{ $fld }
                    ? $data->{rows}->{ $fld } : 5;
      $args->{cols} = exists $data->{cols}->{ $fld }
                    ? $data->{cols}->{ $fld } : 60;
   }
   elsif ($type eq q(textfield)) {
      $args->{size} = exists $data->{sizes}->{ $fld }
                    ? $data->{sizes}->{ $fld } : 10;
   }

   my $text = $self->hacc->$type( $args );

   return $self->hacc->td( { class => q(dataValue) }, $text );
}

sub _check_box {
   my ($self, $r_no, $c_no, $id) = @_; my ($text, $args);

   $args = { name => $self->name.q(_select).$r_no };
   $args->{value} = $id if ($id);
   $text = $self->hacc->checkbox( $args );
   $args = { align => q(center), class => $c_no % 2 == 0 ? q(odd) : q(even) };

   return $self->hacc->td( $args, $text );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
