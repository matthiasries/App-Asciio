
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Create multiple box elements from a text description' => ['C00-m', \&insert_multiple_boxes_from_text_description],
	'Create multiple text elements from a text description' => ['C0S-M', \&insert_multiple_texts_from_text_description],
	'create stencil definition from selected elements' => ['0A0-s', \&create_stencil_definition],
	'Flip transparent element background' => ['C00-t', \&transparent_elements],
	'Undo' => ['C00-z', \&undo],
	'display undo stack statistics' => ['C0S-Z', \&display_undo_stack_statistics],
	'Redo' => ['C00-y', \&redo],
	'Display keyboard mapping' => ['C00-k', \&display_keyboard_mapping],
	'Zoom in' => ['C00-KP_Add', \&zoom, 2],
	'Zoom out' => ['C00-KP_Subtract', \&zoom, -2],
	'help' => ['000-F1', \&display_help],
	) ;

#----------------------------------------------------------------------------------------------

sub display_help
{
my ($self) = @_ ;


$self->display_message_modal(<<EOM) ;

Some very short help.

CTL+k shows you all the keyboard mapping.
	the first entry in the array is the shortcut
	
b, Add a box
B, Add a box, edit the text directly
t, Ad a text element
a, add a wirl arrow (AsciiO arrow)

copy elements with the CTL key
add elements to the selection with shift

quick link:
	select a box
	CTL+SHIFT+ left mouse on the other element
	
d, change the direction of the arrows (selection)
f, flip the arrows (selection)

CTL+m, Add multiple box in one shot
CTL+t, Add multiple boxes in one shot

CTL+g, group elements
CTL+u, ungroup object

Mouse right button shows a context menu.
Double click (may) shows the element editing dialog

This is an developer release. 

EOM
}

#----------------------------------------------------------------------------------------------

sub zoom
{
my ($self, $direction) = @_ ;

my ($family, $size) = $self->get_font() ;

$self->set_font($family, $size + $direction) ;
}

#----------------------------------------------------------------------------------------------

sub create_stencil_definition
{
my ($self) = @_ ;

use Data::Dumper ;
print Dumper [$self->get_selected_elements(1)] ;

print "\nYou must and change the NAME field to something "
	. "unique and remove X Y (or element will be automatically added to asciio)\n" ;
}

#----------------------------------------------------------------------------------------------

sub display_keyboard_mapping
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree $self->{ACTIONS_BY_NAME}, 'Keyboard mapping:';
$self->show_dump_window($self->{ACTIONS_BY_NAME}, 'Keyboard mapping:') ;

}

sub code_to_key
{
my ($modifier_and_code) = @_ ;

use Gtk2::Gdk::Keysyms ;
my %K = %Gtk2::Gdk::Keysyms ;
my %C = map{$K{$_} => $_} keys %K ;

my($modifier, $code) = $modifier_and_code=~ /^(...)(.*)/ ;
my $key = $C{$code} || $code ;

"$modifier-$key" ;
}

#----------------------------------------------------------------------------------------------

sub undo
{
my ($self) = @_ ;

$self->undo(1) ;
}

#----------------------------------------------------------------------------------------------

sub redo
{
my ($self) = @_ ;

$self->redo(1) ;
}


#----------------------------------------------------------------------------------------------

sub display_undo_stack_statistics
{
my ($self) = @_ ;

my $statistics  = { DO_STACK_POINTER => $self->{DO_STACK_POINTER} } ;

my $total_size = 0 ;

for my $stack_element (@{$self->{DO_STACK}})
	{
	push @{$statistics->{ELEMENT_SIZE}}, length($stack_element) ;
	$total_size += length($stack_element) ;
	}

$statistics->{TOTAL_SIZE} = $total_size ;

$self->show_dump_window($statistics, 'Undo stack statistics:') ;
}

#----------------------------------------------------------------------------------------------

sub insert_multiple_boxes_from_text_description
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $text = $self->display_edit_dialog('multiple boxes from input', "--\nA\n--\nB\n--\nC\n--\nD\n--\nE\n" ) ;

if(defined $text && $text ne '')
	{
	my ($current_x, $current_y) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	my ($separator) = split("\n", $text) ;
	
	$text =~ s/$separator\n// ;

	for my $element_text (split("$separator\n", $text))
		{
		chomp $element_text ;
		
		my $new_element = new App::Asciio::stripes::editable_box2
							({
							TITLE => '',
							TEXT_ONLY => $element_text,
							EDITABLE => 1,
							RESIZABLE => 1,
							}) ;
							
		@$new_element{'X', 'Y'} = ($current_x, $current_y) ;
		$current_x += $self->{COPY_OFFSET_X} ; 
		$current_y += $self->{COPY_OFFSET_Y} ;
		
		$self->add_elements($new_element) ;
		}
		
	$self->update_display() ;
	}
}

sub insert_multiple_texts_from_text_description
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $text = $self->display_edit_dialog('multiple texts from input', "--\ntext\n--\ntext\n--\ntext\n--\ntext" ) ;

if(defined $text && $text ne '')
	{
	my ($current_x, $current_y) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
	my ($separator) = split("\n", $text) ;
	
	$text =~ s/$separator\n// ;

	for my $element_text (split("$separator\n", $text))
		{
		chomp $element_text ;
		
		my $new_element = new App::Asciio::stripes::editable_box2
							({
							TITLE => '',
							TEXT_ONLY => $element_text,
							BOX_TYPE => 
								[
								[0, 'top', '.', '-', '.', 1, ],
								[0, 'title separator', '.', '-', '.', 1, ],
								[0, 'body separator', '. ', '|', ' .', 1, ], 
								[0, 'bottom', '\'', '-', '\'', 1, ],
								], 
							EDITABLE => 1,
							RESIZABLE => 1,
							}) ;
							
		@$new_element{'X', 'Y'} = ($current_x, $current_y) ;
		$current_x += $self->{COPY_OFFSET_X} ; 
		$current_y += $self->{COPY_OFFSET_Y} ;
		
		$self->add_elements($new_element) ;
		}
		
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub transparent_elements
{
my ($self) = @_ ;
$self->{OPAQUE_ELEMENTS} ^=1 ;
$self->update_display();
}
	
