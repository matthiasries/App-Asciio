
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'multi_wirl_context_menu' => ['multi_wirl_context_menu',  undef, undef,  \&multi_wirl_context_menu],
	) ;


#----------------------------------------------------------------------------------------------

sub multi_wirl_context_menu
{
my ($self, $popup_x, $popup_y) = @_ ;
my @context_menu_entries ;

my ($character_width, $character_height) = $self->get_character_size() ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements == 1 && 'App::Asciio::stripes::section_wirl_arrow' eq ref $selected_elements[0])
	{
	my $element = $selected_elements[0] ;
	
	my ($x, $y) = $self->closest_character($popup_x - ($element->{X} * $character_width) , $popup_y - ($element->{Y} * $character_height)) ;
	
	push @context_menu_entries, 
		[
		'/add_section', 
		\&add_section_to_section_wirl_arrow,
		{
		ELEMENT => $selected_elements[0], 
		X => $x,
		Y => $y,
		}
		] ;
	}
	
# check if some external context menu configuration exists


return(@context_menu_entries) ;

}

sub add_section_to_section_wirl_arrow
{
my ($self, $data) = @_ ;

$self->create_undo_snapshot() ;

$data->{ELEMENT}->add_section($data->{X}, $data->{Y}) ;

$self->update_display() ;
}

