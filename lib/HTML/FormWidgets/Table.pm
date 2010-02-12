# @(#)$Id$

package HTML::FormWidgets::Table;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.6.%d', q$Rev$ =~ /\d+/gmx );
use parent qw(HTML::FormWidgets);

__PACKAGE__->mk_accessors( qw(add_tip assets data edit hide
                              js_obj number_rows remove_tip select) );

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

   $text = $self->loc( q(tableAddTip) );
   $self->add_tip    ( $self->hint_title.$TTS.$text );
   $text = $self->loc( q(tableRemoveTip) );
   $self->remove_tip ( $self->hint_title.$TTS.$text );
   return;
}

sub render_field {
   my ($self, $args) = @_; my $cells = $NUL; my $data = $self->data;

   $self->number_rows        and $cells .= $self->_render_row_header;
   $self->select eq q(left)  and $cells .= $self->_render_selectbox;

   $cells .= $self->_render_header( $data, $_ ) for (@{ $data->{flds} });

   $self->select eq q(right) and $cells .= $self->_render_selectbox;

   my $hacc = $self->hacc; my $rows = $hacc->tr( $cells ); my $r_no = 0;

   $rows .= $self->_render_row( $data, $_, $r_no++ ) for (@{$data->{values}});

   $self->_add_row_count( $r_no );
   $self->edit and $rows .= $self->_add_edit_row( $data );
   $self->class( q(fullWidth) );

   my $class = $self->prompt ? q(form ) : q(std);

   return $hacc->table( { class => $class }, $rows );
}

# Private methods

sub _add_edit_row {
   my ($self, $data) = @_; my $hacc = $self->hacc; my $cells = $NUL;

   for (0 .. $#{ $data->{flds} }) {
      my $args      = { id => $self->name.q(_add).$_ };
      my $field     = $data->{flds}->[ $_ ];

      $args->{name} = $self->name.q(_).$field;
      $cells       .= $self->_editable_cell( $data, $field, $args );
   }

   my $args = {};

   $args->{class  }  = $args->{name} = q(button);
   $args->{onclick}  = 'return '.$self->js_obj.".addTableRow('";
   $args->{onclick} .= $self->name."', 1)";
   $args->{src    }  = $self->assets.'add_item.png';
   $args->{value  }  = $self->name.q(_add);

   my $text = $hacc->image_button( $args );

   $args    = { class => q(help tips), title => $self->add_tip };
   $text    = $hacc->span( $args, $text );

   if ($self->select) {
      $args             = {};
      $args->{class  }  = $args->{name} = q(button);
      $args->{onclick}  = 'return '.$self->js_obj;
      $args->{onclick} .= ".removeTableRow('".$self->name."')";
      $args->{src    }  = $self->assets.'remove_item.png';
      $args->{value  }  = $self->name.q(_remove);

      my $text1 = $hacc->image_button( $args );

      $args     = { class => q(help tips), title => $self->remove_tip };
      $text    .= $hacc->span( $args, $text1 );
   }

   $cells   .= $hacc->td( $text );

   my $class = $data->{class} || q(dataValue);

   $args     = { class => $class, id => $self->name.q(_add) };

   return $hacc->tr( $args, $cells );
}

sub _add_row_count {
   my ($self, $r_no) = @_;

   my $content = $self->inflate( { name    => $self->name.q(_nrows),
                                   default => $r_no,
                                   type    => q(hidden),
                                   widget  => 1 } );

   push @{ $self->hide }, { content => $content };
   return;
}

sub _check_box {
   my ($self, $r_no, $c_no, $id) = @_; my $hacc = $self->hacc;

   my $args = { name => $self->name.q(_select).$r_no };

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
   my ($self, $data, $field) = @_; my $args = { class => $self->class };

   if (exists $data->{hclass}->{ $field }) {
      $data->{hclass}->{ $field } eq q(hide) and return;
      $args->{class} .= q( ).$data->{hclass}->{ $field };
   }

   exists $data->{widths}->{ $field }
      and $args->{style} = q(width: ).$data->{widths}->{ $field }.q(;);

   exists $data->{wrap  }->{ $field } or $args->{class} .= q( nowrap);

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
         $args->{name   } = $self->name.q(_).$field.$r_no;
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

         $cells .= $hacc->td( $args, $fld_val )."\n";
      }

      $c_no++;
   }

   if ($self->select eq q(right) and $data->{values}->[0]) {
      $cells .= $self->_check_box( $r_no, $c_no++, $val->{id} );
   }

   my $args = { class => q(dataValue), id => $self->name.q(_row).$r_no };

   return $hacc->tr( $args, $cells );
}

sub _render_row_header {
   my $self = shift;

   return $self->hacc->th( { class => $self->class.q( minimal) }, '#' );
}

sub _render_selectbox {
   my $self = shift; my $args = { class => $self->class };

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
