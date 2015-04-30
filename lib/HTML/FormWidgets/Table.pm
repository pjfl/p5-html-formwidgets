package HTML::FormWidgets::Table;

use strict;
use warnings;
use parent 'HTML::FormWidgets';

__PACKAGE__->mk_accessors( qw( data edit hclass number_rows
                               select sortable table_class ) );

my $HASH_CHAR = chr 35;
my $NBSP      = '&#160;';
my $NUL       = q();
my $SPC       = q( );
my $TTS       = q( ~ );

# Private functions
my $_even_or_odd = sub {
   return ($_[ 0 ] + 1) % 2 == 0 ? ' even' : ' odd';
};

my $_column_class = sub {
   return $_even_or_odd->( $_[ 0 ] ).'_col';
};

my $_row_class = sub {
   return $_even_or_odd->( $_[ 0 ] ).'_row';
};

# Private methods
my $_add_row_count = sub {
   my ($self, $n_rows) = @_;

   return $self->add_hidden( '_'.$self->name.'_nrows', $n_rows );
};

my $_check_box = sub {
   my ($self, $r_no, $c_no, $val) = @_; my $hacc = $self->hacc;

   my $class = 'row_select'.$_column_class->( $c_no );
   my $args  = { name => $self->name.".select${r_no}" };

   defined $val->{id} and $args->{value} = $val->{id};

   exists $val->{_meta} and exists $val->{_meta}->{select}
      and defined $val->{_meta}->{select}
      and $val->{_meta}->{select} eq 'checked'
      and $args->{checked} = 'checked';

   return $hacc->td( { class => $class }, $hacc->checkbox( $args ) );
};

my $_drag_icon = sub {
   my ($self, $c_no) = @_; my $hacc = $self->hacc;

   my $span  = $hacc->span( { class => 'drag_icon' } );
   my $class = 'row_drag'.$_column_class->( $c_no );

   return $hacc->td( { class => $class }, $span );
};

my $_drag_header = sub {
   my ($self, $c_no) = @_; my $name = "col${c_no}";

   my $args = { class => $self->hclass.' minimal',
                id    => $self->id.".${name}" };

   return $self->hacc->th( $args, $self->loc( 'Drag' ) );
};

my $_editable_cell = sub {
   my ($self, $data, $field, $args, $c_no) = @_; my $hacc = $self->hacc;

   $args->{class} = $data->{classes}->{ $field } // $self->class;

   exists $data->{maxlengths}->{ $field }
      and $args->{maxlength } = $data->{maxlengths}->{ $field };

   my $map        = { date  => 'textfield',
                      money => 'textfield', numeric => 'textfield' };
   my $type       = $data->{typelist}->{ $field } || 'textfield';
   my $el_type    = defined $map->{ $type } ? $map->{ $type } : $type;
   my $field_type = defined $map->{ $type } ? $type : $NUL;

   if ($el_type eq 'textarea') {
      $args->{cols} = $data->{cols}->{ $field } // 60;
      $args->{rows} = $data->{rows}->{ $field } // 1;
   }
   elsif ($el_type eq 'textfield') {
      exists $data->{sizes}->{ $field }
         and $args->{size } = $data->{sizes}->{ $field };
   }

   my $class  = 'data_field'.($field_type ? " ${field_type}" : $NUL);
      $class .= $_column_class->( $c_no );

   return $hacc->td( { class => $class }, $hacc->$el_type( $args ) );
};

my $_row_number = sub {
   my ($self, $row, $col) = @_; my $args = { class => 'lineNumber minimal' };

   $args->{class} .= $_column_class->( $col );

   return $self->hacc->td( $args, $row );
};

my $_select_header = sub {
   my ($self, $c_no) = @_; my $name = "col${c_no}";

   my $args = { class => $self->hclass, id => $self->id.".${name}" };

   $args->{class} .= $self->edit ? ' select' : ' minimal';

   return $self->hacc->th( $args, $self->loc( 'Select' ) );
};

my $_sort_tip = sub {
   my $self = shift;

   return $self->hint_title.$TTS.$self->loc( 'Sort table rows' );
};

my $_add_edit_row = sub {
   my ($self, $data, $r_no) = @_; my $hacc = $self->hacc;

   my $cells = $NUL; my $c_no = 0;

   for (0 .. $#{ $data->{fields} }) {
      my $args      = { id => $self->id."_add${_}" };
      my $field     = $data->{fields}->[ $_ ];

      $args->{name} = '_'.$self->name."_${field}";
      $cells       .= $self->$_editable_cell( $data, $field, $args, $c_no );
      $c_no++;
   }

   my $add_tip = $self->hint_title.$TTS.$self->loc( 'Add table row' );
   my $text    = $hacc->span( { class => 'add_item_icon' }, $SPC );
   my $args    = { class   => 'icon_button tips add',
                   id      => $self->id.'_add',
                   title   => $add_tip };

   $text       = $hacc->span( $args, $text );

   my $rm_tip  = $self->hint_title.$TTS.$self->loc( 'Remove table row' );
   my $text1   = $hacc->span( { class => 'remove_item_icon' }, $SPC );

   $args       = { class   => 'icon_button tips remove',
                   id      => $self->id.'_remove',
                   title   => $rm_tip };
   $text      .= $hacc->span( $args, $text1 );
   $text       = $hacc->span( { class => 'table_edit_buttons' }, $text );
   $cells     .= $hacc->td( $text );

   my $class   = ($data->{class} // 'edit_row').$_row_class->( $r_no );

   $args       = { class => $class, id => $self->id.'_edit' };

   return $hacc->tr( $args, $cells );
};

my $_field_header = sub {
   my ($self, $data, $field, $c_no) = @_; my $name = "col${c_no}";

   my $args = { class => $self->hclass }; my $type = $NUL;

   if (exists $data->{hclass}->{ $field }) {
      $data->{hclass}->{ $field } eq 'hide' and return;
      $args->{class} .= $SPC.$data->{hclass}->{ $field };
   }

   exists $data->{widths  }->{ $field }
      and $args->{style   } = 'width: '.$data->{widths}->{ $field }.';';
   exists $data->{wrap    }->{ $field } or $args->{class} .= ' nowrap';
   exists $data->{typelist}->{ $field }
      and $type = $data->{typelist}->{ $field };

   $args->{id} = $self->id.".${name}".($type ? ".${type}" : $NUL);

   if ($self->sortable) {
      $args->{class} .= ' sort tips'; $args->{title} = $self->$_sort_tip;
   }

   my $label = $data->{labels}->{ $field } // ucfirst $field;

   return $self->hacc->th( $args, $label );
};

my $_number_header = sub {
   my ($self, $c_no) = @_; my $name = "col${c_no}";

   my $args = { class => $self->hclass.' minimal',
                id    => $self->id.".${name}.numeric" };

   if ($self->sortable) {
      $args->{class} .= ' sort tips'; $args->{title} = $self->$_sort_tip;
   }

   return $self->hacc->th( $args, $HASH_CHAR );
};

my $_render_row = sub {
   my ($self, $data, $val, $r_no) = @_; my $hacc = $self->hacc;

   my $c_no = 0; my $cells = $NUL; my $first_value = $data->{values}->[ 0 ];

   $self->number_rows and $cells .= $self->$_row_number( $r_no + 1, $c_no++ );

   $self->edit eq 'left' and $first_value
      and $cells .= $self->$_drag_icon( $c_no++ );

   $self->select eq 'left' and $first_value
      and $cells .= $self->$_check_box( $r_no, $c_no++, $val );

   for my $field (@{ $data->{fields} }) {
      my $args = {};

      if ($self->edit) {
         $args->{default} = $val->{ $field };
         $args->{name   } = $self->name."_${r_no}_${c_no}";
         $cells .= $self->$_editable_cell( $data, $field, $args, $c_no );
      }
      else {
         exists $data->{hclass}->{ $field }
            and $data->{hclass}->{ $field } eq 'hide' and next;

         my $class = $data->{class} // {}; my $fval = $val->{ $field } // $NBSP;

         $args->{class}  = (ref $class eq 'HASH' && $class->{ $field })
                         ? $class->{ $field } : $self->table_class.'_cell';
         exists $data->{typelist}->{ $field }
            and $args->{class   } .= $SPC.$data->{typelist}->{ $field };
         exists $val->{_meta} and exists  $val->{_meta}->{ $field }
                              and defined $val->{_meta}->{ $field }
            and $args->{class   } .= $SPC.$val->{_meta}->{ $field };
         $args->{class} .= $_column_class->( $c_no );

         $cells .= $hacc->td( $args, $self->inflate( $fval ) );
      }

      $c_no++;
   }

   $self->select eq 'right' and $first_value
      and $cells .= $self->$_check_box( $r_no, $c_no++, $val );

   $self->edit eq 'right' and $first_value
      and $cells .= $self->$_drag_icon( $c_no++ );

   my $class = $self->table_class.'_row'.$_row_class->( $r_no );

   $self->sortable and $class .= ' sortable_row';

   my $args  = { class => $class, id => $self->id.".row${r_no}" };

   return $hacc->tr( $args, "\n".$cells );
};

# Public methods
sub init {
   my ($self, $args) = @_;

   $self->class      ( 'ifield' );
   $self->container  ( 0 );
   $self->data       ( { fields => [], values => [] } );
   $self->edit       ( 0 );
   $self->hclass     ( 'std_header' );
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
   my $class   = $self->prompt ? 'editable' : 'std';
   my $caption = $data->{caption}
               ? "\n".$hacc->caption( $data->{caption} ) : $NUL;

   $self->table_class      or  $self->table_class( $class );
   $self->id               or  $self->id( $self->name || 'table' );
   $self->number_rows      and $cells .= $self->$_number_header( $c_no++ );
   $self->edit   eq 'left' and $cells .= $self->$_drag_header  ( $c_no++ );
   $self->select eq 'left' and $cells .= $self->$_select_header( $c_no++ );

   for (@{ $data->{fields} }) {
      $cells .= $self->$_field_header( $data, $_, $c_no++ );
   }

   $self->select eq 'right' and $cells .= $self->$_select_header( $c_no++ );
   $self->edit   eq 'right' and $cells .= $self->$_drag_header  ( $c_no++ );
   $args = { class => $self->table_class.'_row' };

   my $thead = $hacc->thead( $hacc->tr( $args, $cells ) );

   my $r_no  = 0; my $rows;

   $rows .= $self->$_render_row( $data, $_, $r_no++ ) for (@{ $data->{values}});

   my $tbody = $hacc->tbody( $rows ); $self->$_add_row_count( $r_no );

   my $tfoot = $NUL;

   $self->edit
      and $tfoot = $hacc->tfoot( $self->$_add_edit_row( $data, $r_no ) );

   $self->add_literal_js( 'tables', $self->id, {
      editSide => '"'.$self->edit.'"', selectSide => '"'.$self->select.'"' } );

   $args = { cellspacing => 0,
             class       => $self->table_class.'_table',
             id          => $self->id };

   return $hacc->table( $args, "${caption}\n${thead}\n${tfoot}\n${tbody}" );
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
