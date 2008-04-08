
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Add box no edit' => ['000-b', \&add_element, ['thin_box', 0]],
	'Add box' => ['00S-B', \&add_element, ['thin_box', 1]],
	'Add text' => ['000-t', \&add_element, ['text', 1]],
	'Add if' => ['000-i', \&add_element, ['box/if', 1]],
	'Add process' => ['000-p', \&add_element, ['box/process', 1]],
	'Add arrow' => ['000-a', \&add_element, ['wirl_arrow', 0]],
	'Add arrow double pointed' => ['00S-A', \&add_element, ['wirl_arrow_double_pointed', 0]],
	'Add multi wirl arrow' => ['000-m', \&add_element, ['multi_wirl_arrow', 0]],
	'Add multi wirl arrow double pointed' => ['00S-M', \&add_element, ['multi_wirl_arrow_double_pointed', 0]],
	) ;
	
#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

my ($name, $edit) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->edit() if $edit;

$self->update_display() ;
} ;
