# @(#)$Id$

package HTML::FormWidgets::Table;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip assets data edit hide
                              number_rows remove_tip select
                              sort_tip sortable table_class) );

my $NUL = q();
my $TTS = q( ~ );

sub init {
   my ($self, $args) = @_; my $text;

   $self->assets     ( $NUL );
   $self->class      ( q(table) );
   $self->container  ( 0 );
   $self->data       ( { flds => [], values => [] } );
   $self->edit       ( 0 );
   $self->hide       ( [] );
   $self->hint_title ( $self->loc( q(Hint) ) ) unless ($self->hint_title);
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

   my $c_no    = 0;
   my $cells   = $NUL;
   my $data    = $self->data;
   my $hacc    = $self->hacc;
   my $class   = $self->prompt ? q(editable) : q(std);
   my $caption = $data->{caption}
               ? "\n".$hacc->caption( $data->{caption} ) : $NUL;

   $self->table_class       or  $self->table_class( $class );
   $self->id                or  $self->id( $self->name || q(table) );
   $self->number_rows       and $cells .= $self->_render_row_header( $c_no++ );
   $self->select eq q(left) and $cells .= $self->_render_selectbox ( $c_no++ );

   for (@{ $data->{flds} }) {
      $cells .= $self->_render_header( $data, $_, $c_no++ );
   }

   $self->select eq q(right) and $cells .= $self->_render_selectbox( $c_no++ );
   $args = { class => $self->table_class.q(_head) };

   my $thead = $hacc->thead( $hacc->tr( $args, $cells ) );
   my $r_no  = 0;
   my $rows;

   $rows .= $self->_render_row( $data, $_, $r_no++ ) for (@{ $data->{values} });

   $self->_add_row_count( $r_no );
   $self->edit and $rows .= $self->_add_edit_row( $data );

   my $tbody = $hacc->tbody( $rows );

   $args = { class => $self->table_class, id => $self->id };

   return $hacc->table( $args, "${caption}\n${thead}\n${tbody}" );
}

# Private methods

sub _add_edit_row {
   my ($self, $data) = @_; my $hacc = $self->hacc; my $cells = $NUL;

   for (0 .. $#{ $data->{flds} }) {
      my $args      = { id => $self->id.q(_add).$_ };
      my $field     = $data->{flds}->[ $_ ];

      $args->{name} = q(_).$self->id.q(_).$field;
      $cells       .= $self->_editable_cell( $data, $field, $args );
   }

   my $text   = $hacc->span( { class => q(add_item_icon) }, q( ) );
   my $args   = {
      class   => q(icon_button tips add),
      id      => $self->id.q(_add),
      title   => $self->add_tip };

   $text      = $hacc->span( $args, $text );

   my $text1  = $hacc->span( { class => q(remove_item_icon) }, q( ) );

   $args      = {
      class   => q(icon_button tips remove),
      id      => $self->id.q(_remove),
      title   => $self->remove_tip };
   $text     .= $hacc->span( $args, $text1 );
   $text      = $hacc->span( { class => q(table_edit_buttons) }, $text );
   $cells    .= $hacc->td( $text );
   $args      = { class => $data->{class} || q(edit_row),
                  id    => $self->id.q(_edit) };

   return $hacc->tr( $args, $cells );
}

sub _add_row_count {
   my ($self, $default) = @_;

   my $content = $self->inflate( { name    => q(_).$self->id.q(_nrows),
                                   default => $default,
                                   type    => q(hidden),
                                   widget  => 1 } );

   push @{ $self->hide }, { content => $content };
   return;
}

sub _check_box {
   my ($self, $r_no, $c_no, $id) = @_; my $hacc = $self->hacc;

   my $args = { name => $self->id.q(_select).$r_no };

   $id and $args->{value} = $id;

   my $text  = $hacc->checkbox( $args );
   my $class = q(row_select ).__column_class( $c_no );

   return $hacc->td( { class => $class }, $text );
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

   return $hacc->td( { class => q(data_field) }, $hacc->$type( $args ) );
}

sub _render_header {
   my ($self, $data, $field, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->class };

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
      $args->{class} .= q( sort tips); $args->{title} = $self->sort_tip;
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
         $args->{name   } = $self->id.q(_).$r_no.q(_).$c_no;
         $cells          .= $self->_editable_cell( $data, $field, $args );
      }
      else {
         exists $data->{hclass}->{ $field }
            and $data->{hclass}->{ $field } eq q(hide) and next;

         my $class = $data->{class} || q(data_value);

         $args->{class}  = ref $class eq q(HASH) ? $class->{ $field } : $class;
         exists $data->{typelist}->{ $field }
            and $args->{class   } .= q( ).$data->{typelist}->{ $field };
         $args->{class} .= q( ).__column_class( $c_no );
         exists $data->{wrap}->{ $field } or $args->{class} .= q( nowrap);

         my $fld_val = $self->inflate( $val->{ $field } ) || '&#160;';

         $cells .= $hacc->td( $args, $fld_val );
      }

      $c_no++;
   }

   if ($self->select eq q(right) and $data->{values}->[0]) {
      $cells .= $self->_check_box( $r_no, $c_no++, $val->{id} );
   }

   my $class = $self->table_class.q(_row).($self->sortable
                                       ? q( sortable_row) : $NUL);
   my $args  = { class => $class, id => $self->id.q(_row).$r_no };

   return $hacc->tr( $args, "\n".$cells );
}

sub _render_row_header {
   my ($self, $c_no) = @_; my $name = q(col).$c_no;

   my $args = { class => $self->class.q( minimal),
                id    => $self->id.q(.).$name.q(.numeric) };

   if ($self->sortable) {
      $args->{class} .= q( sort tips); $args->{title} = $self->sort_tip;
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

   $args->{class} .= q( ).__column_class( $col );

   return $self->hacc->td( $args, $row );
}

# Private subroutines

sub __column_class {
   return $_[ 0 ] % 2 == 0 ? q(even) : q(odd);
}

1;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
