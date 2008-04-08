
package App::Asciio ;
$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Data::TreeDumper::Renderer::GTK ;

#-----------------------------------------------------------------------------

sub get_color_from_user
{
my ($self, $previous_color) = @_ ;

my $color = Gtk2::Gdk::Color->new (@{$previous_color});
my $dialog = Gtk2::ColorSelectionDialog->new ("Changing color");

my $colorsel = $dialog->colorsel;

$colorsel->set_previous_color ($color);
$colorsel->set_current_color ($color);
$colorsel->set_has_palette (TRUE);

my $response = $dialog->run;

if ($response eq 'ok') 
	{
	$color = $colorsel->get_current_color;
	}

$dialog->destroy;

return [$color->red, $color->green , $color->blue]  ;
}

#-----------------------------------------------------------------------------

sub show_dump_window
{
my ($self, $data, $title, @dumper_setup) = @_ ;

my $treedumper = Data::TreeDumper::Renderer::GTK->new
				(
				data => $data,
				title => $title,
				dumper_setup => {@dumper_setup}
				);
		
$treedumper->modify_font(Gtk2::Pango::FontDescription->from_string ('monospace'));
$treedumper->collapse_all;

# some boilerplate to get the widget onto the screen...
my $window = Gtk2::Window->new;

my $scroller = Gtk2::ScrolledWindow->new;
$scroller->add ($treedumper);

$window->add ($scroller);
$window->set_default_size(640, 1000) ;
$window->show_all;
}

#-----------------------------------------------------------------------------

sub display_message_modal
{
my ($self, $message) = @_ ;

my $window = new Gtk2::Window() ;

my $dialog = Gtk2::MessageDialog->new 
	(
	$window,
	'destroy-with-parent' ,
	'info' ,
	'close' ,
	$message ,
	) ;

$dialog->signal_connect(response => sub { $dialog->destroy ; 1 }) ;
$dialog->run() ;
}

#-----------------------------------------------------------------------------

sub display_yes_no_cancel_dialog
{
my ($self, $title, $text) = @_ ;

my $window = new Gtk2::Window() ;

my $dialog = Gtk2::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);
$dialog->add_button ('gtk-yes' => 'yes');
$dialog->add_button ('gtk-no' => 'no');
$dialog->add_button ('gtk-cancel' => 'cancel');

my $lable = Gtk2::Label->new($text);
$dialog->vbox->add ($lable);
$lable->show;

my $result = $dialog->run() ;

$dialog->destroy ;

return $result ;
}

#-----------------------------------------------------------------------------

sub display_quit_dialog
{
my ($self, $title, $text) = @_ ;

my $window = new Gtk2::Window() ;

my $dialog = Gtk2::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);
$dialog->add_button ('Continue editing' => 'no');
$dialog->add_button ('Quit and loose changes' => 'yes');

my $lable = Gtk2::Label->new($text);
$dialog->vbox->add ($lable);
$lable->show;

my $result = $dialog->run() ;

$dialog->destroy ;

return $result ;
}
#-----------------------------------------------------------------------------

sub display_edit_dialog
{
my ($self, $title, $text) = @_ ;

my $window = new Gtk2::Window() ;

my $dialog = Gtk2::Dialog->new($title, $window, 'destroy-with-parent')  ;
$dialog->set_default_size (300, 150);
$dialog->add_button ('gtk-close' => 'close');

my $textview = Gtk2::TextView->new;
$textview->modify_font (Gtk2::Pango::FontDescription->from_string ('monospace 10'));

my $buffer = $textview->get_buffer;
 $buffer->insert ($buffer->get_end_iter, $text);

$dialog->vbox->add ($textview);
$textview->show;


$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($buffer->get_start_iter, $buffer->get_end_iter, TRUE) ;
 $dialog->destroy ;


return $new_text
}

#-----------------------------------------------------------------------------

sub get_file_name
{
my ($self, $type) = @_ ;

my $file_name = '' ;

my $file_chooser = Gtk2::FileChooserDialog->new 
				(
				$type, undef, $type,
				'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok'
				);

$file_name = $file_chooser->get_filename if ('ok' eq $file_chooser->run) ;
	
$file_chooser->destroy;

return $file_name ;
}

#-----------------------------------------------------------------------------

sub display_box_edit_dialog
{
my ($rows, $title, $text) = @_ ;

my $window = new Gtk2::Window() ;

my $dialog = Gtk2::Dialog->new('Box attributes', $window, 'destroy-with-parent')  ;
$dialog->set_default_size (450, 305);
$dialog->add_button ('gtk-close' => 'close');

#~ my $vbox = $dialog->vbox ;
my $dialog_vbox = $dialog->vbox ;

my $vbox = Gtk2::VBox->new (FALSE, 5);
$dialog_vbox->pack_start ($vbox, TRUE, TRUE, 0);

$vbox->pack_start (Gtk2::Label->new (""),
		 FALSE, FALSE, 0);

my $sw = Gtk2::ScrolledWindow->new;
$sw->set_shadow_type ('etched-in');
$sw->set_policy ('automatic', 'automatic');
$vbox->pack_start ($sw, TRUE, TRUE, 0);

# create model
my $model = create_model ($rows);

# create tree view
my $treeview = Gtk2::TreeView->new_with_model ($model);
$treeview->set_rules_hint (TRUE);
$treeview->get_selection->set_mode ('single');

add_columns($treeview, $rows);

$sw->add($treeview);

# title
my $titleview = Gtk2::TextView->new;
$titleview->modify_font (Gtk2::Pango::FontDescription->from_string ('monospace 10'));
my $title_buffer = $titleview->get_buffer ;
$title_buffer->insert ($title_buffer->get_end_iter, $title);

$vbox->add ($titleview);
$titleview->show;

# text 
my $textview = Gtk2::TextView->new;
$textview->modify_font (Gtk2::Pango::FontDescription->from_string ('monospace 10'));

my $text_buffer = $textview->get_buffer;
$text_buffer->insert ($text_buffer->get_end_iter, $text);

$vbox->add ($textview);
$textview->show;

# some buttons
#~ my $hbox = Gtk2::HBox->new (TRUE, 4);
#~ $vbox->pack_start ($hbox, FALSE, FALSE, 0);

#~ my $button = Gtk2::Button->new ("Add item");
#~ $button->show() ;
#~ $button->signal_connect (clicked => \&add_item, $model);
#~ $hbox->pack_start ($button, TRUE, TRUE, 0);

#~ $button = Gtk2::Button->new ("Remove item");
#~ $button->signal_connect (clicked => \&remove_item, $treeview);
#~ $hbox->pack_start ($button, TRUE, TRUE, 0);

#~ $hbox->show() ;

$treeview->show() ;
$vbox->show() ;
$sw->show() ;

$dialog->run() ;

my $new_text =  $textview->get_buffer->get_text($text_buffer->get_start_iter, $text_buffer->get_end_iter, TRUE) ;
my $new_title =  $titleview->get_buffer->get_text($title_buffer->get_start_iter, $title_buffer->get_end_iter, TRUE) ;

$dialog->destroy ;

return($new_text, $new_title) ;
}

#-----------------------------------------------------------------------------

sub create_model 
{
my ($rows) = @_ ;

my $model = Gtk2::ListStore->new(qw/Glib::Boolean Glib::String  Glib::String Glib::String Glib::String Glib::Boolean/);

foreach my $row (@{$rows}) 
	{
	my $iter = $model->append;

	my $column = 0 ;
	$model->set ($iter, map {$column++, $_} @{$row}) ;
	}

return $model;
}

#-----------------------------------------------------------------------------

sub add_columns 
{
my ($treeview, $rows) = @_ ;
my $model = $treeview->get_model;

# column for fixed toggles
my $renderer = Gtk2::CellRendererToggle->new;
$renderer->signal_connect (toggled => \&display_toggled, [$model, $rows]) ;

my $column = Gtk2::TreeViewColumn->new_with_attributes 
			(
			'show',
			$renderer,
			active => 0
			) ;
			
$column->set_sizing('fixed') ;
$column->set_fixed_width(70) ;
$treeview->append_column($column) ;

# column for row titles
my $row_renderer = Gtk2::CellRendererText->new;
$row_renderer->set_data (column => 1);

$treeview->insert_column_with_attributes(-1, '', $row_renderer, text => 1) ;

#~ $column->set_sort_column_id (COLUMN_NUMBER);

my $current_column = 2 ;
for my $column_title('left', 'body', 'right')
	{
	my $renderer = Gtk2::CellRendererText->new;
	$renderer->signal_connect (edited => \&cell_edited, [$model, $rows]);
	$renderer->set_data (column => $current_column );

	$treeview->insert_column_with_attributes 
				(
				-1, $column_title, $renderer,
				text => $current_column,
				editable => 5, 
				);
				
	$current_column++ ;
	}
}

#-----------------------------------------------------------------------------

sub cell_edited 
{
my ($cell, $path_string, $new_text, $model_and_rows) = @_;

my ($model, $rows) = @{$model_and_rows} ;

my $path = Gtk2::TreePath->new_from_string ($path_string);
my $column = $cell->get_data ("column");
my $iter = $model->get_iter($path);
my $row = ($path->get_indices)[0];

$rows->[$row][$column] = $new_text ;

$model->set($iter, $column, $new_text);
}

#-----------------------------------------------------------------------------

sub display_toggled 
{
my ($cell, $path_string, $model_and_rows) = @_;

my ($model, $rows) = @{$model_and_rows} ;

my $column = $cell->get_data ('column');
my $path = Gtk2::TreePath->new ($path_string) ;
my $iter = $model->get_iter ($path);
my $display = $model->get($iter, 0);

$rows->[$path_string][$column] = $display ^ 1 ;

$model->set ($iter, 0, $display ^ 1);
}

#-----------------------------------------------------------------------------

#~ sub add_item {
  #~ my ($button, $model) = @_;

  #~ push @articles, {
	#~ number => 0,
	#~ product => "Description here",
	#~ editable => TRUE,
  #~ };

  #~ my $iter = $model->append;
  #~ $model->set ($iter,
               #~ COLUMN_NUMBER, $articles[-1]{number},
               #~ COLUMN_PRODUCT, $articles[-1]{product},
               #~ COLUMN_EDITABLE, $articles[-1]{editable});
#~ }

#~ sub remove_item {
  #~ my ($widget, $treeview) = @_;
  #~ my $model = $treeview->get_model;
  #~ my $selection = $treeview->get_selection;

  #~ my $iter = $selection->get_selected;
  #~ if ($iter) {
      #~ my $path = $model->get_path ($iter);
      #~ my $i = ($path->get_indices)[0];
      #~ $model->remove ($iter);

      #~ splice @articles, $i;
  #~ }
#~ }

#-----------------------------------------------------------------------------

1 ;
