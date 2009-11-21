package HTML::FormWidgets::Table;

# @(#)$Id$

use strict;
use warnings;
use parent qw(HTML::FormWidgets);

use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );

__PACKAGE__->mk_accessors( qw(add_tip assets data edit hide
                              js_obj number_rows remove_tip select) );

my $TTS = q( ~ );

sub _init {
   my ($self, $args) = @_; my $text;

   $self->assets     ( q() );
   $self->class      ( q(small table) );
   $self->container  ( 0 );
   $self->data       ( { flds => [], values => [] } );
   $self->edit       ( 0 );
   $self->hide       ( [] );
   $self->hint_title ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->js_obj     ( q(behaviour.table) );
   $self->number_rows( 0 );
   $self->select     ( q() );

   $text = $self->loc( q(tableAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(tableRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub _render {
   my ($self, $args) = @_;
   my ($class, $fld, $fld_val, $r_no, $rows, $text, $text1, $type, $val);

   my $c_no  = 0;
   my $cells = q();
   my $data  = $self->data;
   my $hacc  = $self->hacc;

   if ($self->number_rows) {
      $args   = { class => $self->class.q( minimal) };
      $cells .= $hacc->th( $args, '#' );
   }

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

      if (exists $data->{widths}->{ $fld }) {
         $args->{style} = q(width: ).$data->{widths}->{ $fld }.q(;);
      }

      $args->{class} .= q( nowrap) unless (exists $data->{wrap}->{ $fld });
      $cells         .= $hacc->th( $args, $data->{labels}->{ $fld } );
   }

   if ($self->select eq q(right)) {
      $args           = { class => $self->class };
      $args->{class} .= $self->edit ? q( select) : q( minimal);
      $cells         .= $hacc->th( $args, 'Select' );
   }

   $rows = $hacc->tr( $cells ); $r_no = 0;

   for $val (@{ $data->{values} }) {
      $cells = q(); $c_no = 0;

      if ($self->number_rows) {
         $cells .= $self->_row_number( $r_no + 1, $c_no++ );
      }

      if ($self->select eq q(left) and $data->{values}->[0]) {
         $cells .= $self->_check_box( $r_no, $c_no, $val->{id} ); $c_no++;
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

            $fld_val = $self->inflate( $val->{ $fld } ) || q(&nbsp;);
            $cells  .= $hacc->td( $args, $fld_val )."\n";
         }

         $c_no++;
      }

      if ($self->select eq q(right) and $data->{values}->[0]) {
         $cells .= $self->_check_box( $r_no, $c_no, $val->{id} );
      }

      $args  = { class => q(dataValue), id => $self->name.q(_row).$r_no };
      $rows .= $hacc->tr( $args, $cells ); $r_no++;
   }

   my $content = $self->inflate( { name    => $self->name.q(_nrows),
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

   $self->class( q(fullWidth) );

   $class = $self->prompt ? q(form ) : q(std);

   return $hacc->table( { class => $class }, $rows );
}

# Private methods

sub _check_box {
   my ($self, $r_no, $c_no, $id) = @_; my ($text, $args);

   $args = { name => $self->name.q(_select).$r_no };
   $args->{value} = $id if ($id);
   $text = $self->hacc->checkbox( $args );
   $args = { align => q(center), class => $c_no % 2 == 0 ? q(even) : q(odd) };

   return $self->hacc->td( $args, $text );
}

sub _editable_cell {
   my ($self, $data, $fld, $args) = @_;

   $args->{class} = q(ifield);

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

   return $self->hacc->td( { class => q(dataField) }, $text );
}

sub _row_number {
   my ($self, $row, $col) = @_;

   my $args = { class => $self->class.q( lineNumber minimal) };

   $args->{class} .= $col % 2 == 0 ? q( even) : q( odd);

   return $self->hacc->td( $args, $row );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
