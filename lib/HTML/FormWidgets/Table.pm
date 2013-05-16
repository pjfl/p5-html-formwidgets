# @(#)$Ident: Table.pm 2013-05-16 14:19 pjf ;

package HTML::FormWidgets::Table;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.19.%d', q$Rev: 1 $ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(data edit hclass number_rows
                              select sortable table_class) );

my $HASH_CHAR = chr 35;
my $NBSP      = '&#160;';
my $NUL       = q();
my $TTS       = q( ~ );

sub init {
   my ($self, $args) = @_;

   $self->class      ( q(ifield) );
   $self->container  ( 0 );
   $self->data       ( { fields => [], values => [] } );
   $self->edit       ( 0 );
   $self->hclass     ( q(normal) );
   $self->number_rows( 0 );
   $self->select     ( 0 );
   $self->sortable   ( 0 );
   $self->table_class( undef );
   return;
}

sub render_field {
   my ($self, $args) = @_;

   my $c_no    = 0;
   my $cells   = $NUL;
   my $data    = $self->data;
   my $hacc    = $self->hacc;
   my $class   = $self->prompt ? q(editable) : q(std);
   my $caption = $data->{caption}
               ? "\n".$hacc->caption( $data->{caption} ) : $NUL;

   $self->table_class       or  $self->table_class( $class );
   $self->id                or  $self->id( $self->name || q(table) );
   $self->number_rows       and $cells .= $self->_number_header( $c_no++ );
   $self->edit   eq q(left) and $cells .= $self->_drag_header  ( $c_no++ );
   $self->select eq q(left) and $cells .= $self->_select_header( $c_no++ );

   for (@{ $data->{fields} }) {
      $cells .= $self->_field_header( $data, $_, $c_no++ );
   }

   $self->select eq q(right) and $cells .= $self->_select_header( $c_no++ );
   $self->edit   eq q(right) and $cells .= $self->_drag_header  ( $c_no++ );
   $args = { class => $self->table_class.q(_head) };

   my $thead = $hacc->thead( $hacc->tr( $args, $cells ) );

   my $r_no  = 0; my $rows;

   $rows .= $self->_render_row( $data, $_, $r_no++ ) for (@{ $data->{values} });

   my $tbody = $hacc->tbody( $rows ); $self->_add_row_count( $r_no );

   my $tfoot = q();

   $self->edit
      and $tfoot = $hacc->tfoot( $self->_add_edit_row( $data, $r_no ) );

   $self->add_literal_js( 'tables', $self->id, {
      editSide => '"'.$self->edit.'"', selectSide => '"'.$self->select.'"' } );

   $args = { cellspacing => 0, class => $self->table_class, id => $self->id };

   return $hacc->table( $args, "${caption}\n${thead}\n${tfoot}\n${tbody}" );
}

# Private methods

sub _add_edit_row {
   my ($self, $data, $r_no) = @_; my $hacc = $self->hacc;

   my $cells = $NUL; my $c_no = 0;

   for (0 .. $#{ $data->{fields} }) {
      my $args      = { id => $self->id.q(_add).$_ };
      my $field     = $data->{fields}->[ $_ ];

      $args->{name} = q(_).$self->name.q(_).$field;
      $cells       .= $self->_editable_cell( $data, $field, $args, $c_no );
      $c_no++;
   }

   my $add_tip = $self->hint_title.$TTS.$self->loc( q(Add_table_row) );
   my $text    = $hacc->span( { class => q(add_item_icon) }, q( ) );
   my $args    = { class   => q(icon_button tips add),
                   id      => $self->id.q(_add),
                   title   => $add_tip };

   $text       = $hacc->span( $args, $text );

   my $rm_tip  = $self->hint_title.$TTS.$self->loc( q(Remove_table_row) );
   my $text1   = $hacc->span( { class => q(remove_item_icon) }, q( ) );

   $args       = { class   => q(icon_button tips remove),
                   id      => $self->id.q(_remove),
                   title   => $rm_tip };
   $text      .= $hacc->span( $args, $text1 );
   $text       = $hacc->span( { class => q(table_edit_buttons) }, $text );
   $cells     .= $hacc->td( $text );

   my $class   = ($data->{class} || q(edit_row)).__row_class( $r_no );

   $args       = { class => $class, id => $self->id.q(_edit) };

   return $hacc->tr( $args, $cells );
}

sub _add_row_count {
   my ($self, $n_rows) = @_;

   return $self->add_hidden( q(_).$self->name.q(_nrows), $n_rows );
}

sub _check_box {
   my ($self, $r_no, $c_no, $val) = @_; my $hacc = $self->hacc;

   my $class = q(row_select).__column_class( $c_no );
   my $args  = { name => $self->name.".select${r_no}" };

   defined $val->{id} and $args->{value} = $val->{id};

   exists $val->{_meta} and exists $val->{_meta}->{select}
      and defined $val->{_meta}->{select}
      and $val->{_meta}->{select} eq q(checked)
      and $args->{checked} = q(checked);

   return $hacc->td( { class => $class }, $hacc->checkbox( $args ) );
}

sub _drag_icon {
   my ($self, $c_no) = @_; my $hacc = $self->hacc;

   my $span  = $hacc->span( { class => q(drag_icon) } );
   my $class = q(row_drag).__column_class( $c_no );

   return $hacc->td( { class => $class }, $span );
}

sub _drag_header {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->hclass.q( minimal),
                id    => $self->id.q(.).$name };

   return $self->hacc->th( $args, $self->loc( 'Drag' ) );
}

sub _editable_cell {
   my ($self, $data, $field, $args, $c_no) = @_; my $hacc = $self->hacc;

   $args->{class} = $data->{classes}->{ $field } || $self->class;

   exists $data->{maxlengths}->{ $field }
      and $args->{maxlength} = $data->{maxlengths}->{ $field };

   my $map        = { date  => q(textfield),
                      money => q(textfield), numeric => q(textfield) };
   my $type       = $data->{typelist}->{ $field } || q(textfield);
   my $el_type    = defined $map->{ $type } ? $map->{ $type } : $type;
   my $field_type = defined $map->{ $type } ? $type : q();

   if ($el_type eq q(textarea)) {
      $args->{cols} = $data->{cols}->{ $field } || 60;
      $args->{rows} = $data->{rows}->{ $field } || 1;
   }
   elsif ($el_type eq q(textfield)) {
      exists $data->{sizes}->{ $field }
         and $args->{size} = $data->{sizes}->{ $field };
   }

   my $class  = q(data_field).($field_type ? " ${field_type}" : q());
      $class .= __column_class( $c_no );

   return $hacc->td( { class => $class }, $hacc->$el_type( $args ) );
}

sub _field_header {
   my ($self, $data, $field, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->hclass };

   if (exists $data->{hclass}->{ $field }) {
      $data->{hclass}->{ $field } eq q(hide) and return;
      $args->{class} .= q( ).$data->{hclass}->{ $field };
   }

   exists $data->{widths}->{ $field }
      and $args->{style} = q(width: ).$data->{widths}->{ $field }.q(;);

   exists $data->{wrap  }->{ $field } or $args->{class} .= q( nowrap);

   my $type = exists $data->{typelist}->{ $field }
            ? $data->{typelist}->{ $field } : $NUL;

   $args->{id} = $self->id.q(.).$name.($type ? q(.).$type : $NUL);

   if ($self->sortable) {
      $args->{class} .= q( sort tips); $args->{title} = $self->_sort_tip;
   }

   return $self->hacc->th( $args, $data->{labels}->{ $field } );
}

sub _number_header {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->hclass.q( minimal),
                id    => $self->id.q(.).$name.q(.numeric) };

   if ($self->sortable) {
      $args->{class} .= q( sort tips); $args->{title} = $self->_sort_tip;
   }

   return $self->hacc->th( $args, $HASH_CHAR );
}

sub _render_row {
   my ($self, $data, $val, $r_no) = @_; my $hacc = $self->hacc;

   my $c_no = 0; my $cells = $NUL; my $first_value = $data->{values}->[ 0 ];

   $self->number_rows and $cells .= $self->_row_number( $r_no + 1, $c_no++ );

   $self->edit eq q(left) and $first_value
      and $cells .= $self->_drag_icon( $c_no++ );

   $self->select eq q(left) and $first_value
      and $cells .= $self->_check_box( $r_no, $c_no++, $val );

   for my $field (@{ $data->{fields} }) {
      my $args = {};

      if ($self->edit) {
         $args->{default} = $val->{ $field };
         $args->{name   } = $self->name.q(_).$r_no.q(_).$c_no;
         $cells .= $self->_editable_cell( $data, $field, $args, $c_no );
      }
      else {
         exists $data->{hclass}->{ $field }
            and $data->{hclass}->{ $field } eq q(hide) and next;

         my $class = $data->{class}   || q(data_value);
         my $fval  = $val->{ $field } || $NBSP;

         $args->{class}  = ref $class eq q(HASH) ? $class->{ $field } : $class;
         exists $data->{typelist}->{ $field }
            and $args->{class   } .= q( ).$data->{typelist}->{ $field };
         exists $data->{wrap}->{ $field } or $args->{class} .= q( nowrap);
         exists $val->{_meta} and exists  $val->{_meta}->{ $field }
                              and defined $val->{_meta}->{ $field }
            and $args->{class   } .= q( ).$val->{_meta}->{ $field };
         $args->{class} .= __column_class( $c_no );

         $cells .= $hacc->td( $args, $self->inflate( $fval ) );
      }

      $c_no++;
   }

   $self->select eq q(right) and $first_value
      and $cells .= $self->_check_box( $r_no, $c_no++, $val );

   $self->edit eq q(right) and $first_value
      and $cells .= $self->_drag_icon( $c_no++ );

   my $class = $self->table_class.q(_row).__row_class( $r_no );

   $self->sortable and $class .= q( sortable_row);

   my $args  = { class => $class, id => $self->id.q(.row).$r_no };

   return $hacc->tr( $args, "\n".$cells );
}

sub _row_number {
   my ($self, $row, $col) = @_;

   my $args = { class => q(lineNumber minimal) };

   $args->{class} .= __column_class( $col );

   return $self->hacc->td( $args, $row );
}

sub _select_header {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->hclass, id => $self->id.q(.).$name };

   $args->{class} .= $self->edit ? q( select) : q( minimal);

   return $self->hacc->th( $args, $self->loc( 'Select' ) );
}

sub _sort_tip {
   my $self = shift;

   return $self->hint_title.$TTS.$self->loc( q(Sort_table_rows) );
}

# Private subroutines

sub __column_class {
   return __even_or_odd( $_[ 0 ] ).q(_col);
}

sub __even_or_odd {
   return ($_[ 0 ] + 1) % 2 == 0 ? q( even) : q( odd);
}

sub __row_class {
   return __even_or_odd( $_[ 0 ] ).q(_row);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
