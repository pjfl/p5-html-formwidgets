# @(#)$Id$

package HTML::FormWidgets::Table;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip assets data edit hide js_obj
                              number_rows remove_tip select
                              sort_tip sortable table_class) );

my $NUL = q();
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->assets     ( $NUL );
   $self->class      ( q(small table) );
   $self->container  ( 0 );
   $self->data       ( { flds => [], values => [] } );
   $self->edit       ( 0 );
   $self->hide       ( [] );
   $self->hint_title ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
   $self->js_obj     ( q(behaviour.table) );
   $self->number_rows( 0 );
   $self->select     ( $NUL );
   $self->sortable   ( 0 );
   $self->table_class( undef );

   $text = $self->loc( q(Add_table_row) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(Remove_table_row) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(Sort_table_rows) );
   $self->sort_tip   ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $cells = $NUL; my $c_no = 0; my $data = $self->data;

   $self->id                or  $self->id( $self->name || q(table) );
   $self->number_rows       and $cells .= $self->_render_row_header( $c_no++ );
   $self->select eq q(left) and $cells .= $self->_render_selectbox ( $c_no++ );

   for (@{ $data->{flds} }) {
      $cells .= $self->_render_header( $data, $_, $c_no++ );
   }

   $self->select eq q(right) and $cells .= $self->_render_selectbox( $c_no++ );

   my $hacc = $self->hacc; my $rows = $hacc->tr( $cells ); my $r_no = 0;

   $rows .= $self->_render_row( $data, $_, $r_no++ ) for (@{$data->{values}});

   $self->_add_row_count( $r_no );
   $self->edit and $rows .= $self->_add_edit_row( $data );
   $self->class( $self->table_class || q(fullWidth) );

   my $class = $self->table_class || ($self->prompt ? q(form) : q(std));

   $args = { class => $class, id => $self->id };

   return $hacc->table( $args, "\n".$rows );
}

# Private methods

sub _add_edit_row {
   my ($self, $data) = @_; my $hacc = $self->hacc; my $cells = $NUL;

   for (0 .. $#{ $data->{flds} }) {
      my $args      = { id => $self->id.q(_add).$_ };
      my $field     = $data->{flds}->[ $_ ];

      $args->{name} = $self->id.q(_).$field;
      $cells       .= $self->_editable_cell( $data, $field, $args );
   }

   my $args = {};

   $args->{class  }  = $args->{name} = q(button);
   $args->{onclick}  = 'return '.$self->js_obj.".addTableRow('";
   $args->{onclick} .= $self->id."', 1)";
   $args->{src    }  = $self->assets.'add_item.png';
   $args->{value  }  = $self->id.q(_add);

   my $text = $hacc->image_button( $args );

   $args    = { class => q(help tips), title => $self->add_tip };
   $text    = $hacc->span( $args, $text );

   if ($self->select) {
      $args             = {};
      $args->{class  }  = $args->{name} = q(button);
      $args->{onclick}  = 'return '.$self->js_obj;
      $args->{onclick} .= ".removeTableRow('".$self->id."')";
      $args->{src    }  = $self->assets.'remove_item.png';
      $args->{value  }  = $self->id.q(_remove);

      my $text1 = $hacc->image_button( $args );

      $args     = { class => q(help tips), title => $self->remove_tip };
      $text    .= $hacc->span( $args, $text1 );
   }

   $cells   .= $hacc->td( $text );

   my $class = $data->{class} || q(dataValue);

   $args     = { class => $class, id => $self->id.q(_add) };

   return $hacc->tr( $args, $cells );
}

sub _add_row_count {
   my ($self, $r_no) = @_;

   my $content = $self->inflate( { name    => $self->id.q(_nrows),
                                   default => $r_no,
                                   type    => q(hidden),
                                   widget  => 1 } );

   push @{ $self->hide }, { content => $content };
   return;
}

sub _check_box {
   my ($self, $r_no, $c_no, $id) = @_; my $hacc = $self->hacc;

   my $args = { name => $self->id.q(_select).$r_no };

   $id and $args->{value} = $id;

   my $text = $hacc->checkbox( $args );

   $args = { align => q(center), class => $c_no % 2 == 0 ? q(even) : q(odd) };

   return $hacc->td( $args, $text );
}

sub _editable_cell {
   my ($self, $data, $field, $args) = @_; my $hacc = $self->hacc;

   $args->{class} = q(ifield);

   exists $data->{maxlengths}->{ $field }
      and $args->{maxlength} = $data->{maxlengths}->{ $field };

   my $type = $data->{typelist}->{ $field } || q(textfield);

   if ($type eq q(textarea)) {
      $args->{rows} = exists $data->{rows}->{ $field }
                    ? $data->{rows}->{ $field } : 5;
      $args->{cols} = exists $data->{cols}->{ $field }
                    ? $data->{cols}->{ $field } : 60;
   }
   elsif ($type eq q(textfield)) {
      $args->{size} = exists $data->{sizes}->{ $field }
                    ? $data->{sizes}->{ $field } : 10;
   }

   return $hacc->td( { class => q(dataField) }, $hacc->$type( $args ) );
}

sub _render_header {
   my ($self, $data, $field, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->class, id => $self->id.q(_).$name };

   if (exists $data->{hclass}->{ $field }) {
      $data->{hclass}->{ $field } eq q(hide) and return;
      $args->{class} .= q( ).$data->{hclass}->{ $field };
   }

   exists $data->{widths  }->{ $field }
      and $args->{style} = q(width: ).$data->{widths}->{ $field }.q(;);

   exists $data->{wrap    }->{ $field } or $args->{class} .= q( nowrap);

   my $type = exists $data->{typelist}->{ $field }
            ? $data->{typelist}->{ $field } : $NUL;

   if ($self->sortable) {
      $args->{onclick}
         = $self->js_obj.".sortRows( '".$self->id."', '$name', '$type')";
      $args->{class} .= q( sort tips);
      $args->{title}  = $self->sort_tip;
   }

   return $self->hacc->th( $args, $data->{labels}->{ $field } );
}

sub _render_row {
   my ($self, $data, $val, $r_no) = @_;

   my $c_no = 0; my $cells = $NUL; my $hacc = $self->hacc;

   $self->number_rows and $cells .= $self->_row_number( $r_no + 1, $c_no++ );

   if ($self->select eq q(left) and $data->{values}->[0]) {
      $cells .= $self->_check_box( $r_no, $c_no++, $val->{id} );
   }

   for my $field (@{ $data->{flds} }) {
      my $args = {};

      if ($self->edit) {
         $args->{default} = $val->{ $field };
         $args->{name   } = $self->id.q(_).$field.$r_no;
         $cells          .= $self->_editable_cell( $data, $field, $args );
      }
      else {
         exists $data->{hclass}->{ $field }
            and $data->{hclass}->{ $field } eq q(hide) and next;

         $args->{align} = exists $data->{align}->{ $field }
                        ? $data->{align}->{ $field } : q(left);

         my $class = $data->{class} || q(dataValue);

         if (ref $class and exists $class->{ $field }) {
            $args->{class} = $class->{ $field };
         }
         else { $args->{class} = $class }

         $args->{class} .= $c_no % 2 == 0 ? q( even) : q( odd);
         exists $data->{wrap}->{ $field } or $args->{class} .= q( nowrap);

         my $fld_val = $self->inflate( $val->{ $field } ) || q(&nbsp;);

         $cells .= $hacc->td( $args, $fld_val );
      }

      $c_no++;
   }

   if ($self->select eq q(right) and $data->{values}->[0]) {
      $cells .= $self->_check_box( $r_no, $c_no++, $val->{id} );
   }

   my $args = { class => q(dataValue), id => $self->id.q(_row).$r_no };

   return $hacc->tr( $args, "\n".$cells );
}

sub _render_row_header {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->class.q( minimal),
                id    => $self->id.q(_).$name };

   if ($self->sortable) {
      $args->{onclick}
         = $self->js_obj.".sortRows( '".$self->id."', '$name', 'numeric' )";
      $args->{class} .= q( sort tips);
      $args->{title}  = $self->sort_tip;
   }

   return $self->hacc->th( $args, '#' );
}

sub _render_selectbox {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->class, id => $self->id.q(_).$name };

   $args->{class} .= $self->edit ? q( select) : q( minimal);

   return $self->hacc->th( $args, 'Select' );
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
