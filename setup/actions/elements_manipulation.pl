
#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Select next element' => ['000-Tab', \&select_next_element],
	'Select previous element' => ['00S-ISO_Left_Tab', \&select_previous_element],
	
	'Select all elements' => ['C00-a', \&select_all_elements],
	'Delete selected elements' =>  ['000-Delete', \&delete_selected_elements],

	'Group selected elements' => ['C00-g', \&group_selected_elements],
	'Ungroup selected elements' => ['C00-u', \&ungroup_selected_elements],
	
	'Move selected elements to the front' => ['C00-f', \&move_selected_elements_to_front],
	'Move selected elements to the back' => ['C00-b', \&move_selected_elements_to_back],
	
	'Move selected elements left' => ['000-Left', \&move_selection_left],
	'Move selected elements right' => ['000-Right', \&move_selection_right],
	'Move selected elements up' => ['000-Up', \&move_selection_up],
	'Move selected elements down' => ['000-Down', \&move_selection_down],
	
	'Change elements background color' => ['000-c', \&change_elements_colors, 0],
	'Change elements foreground color' => ['00S-C', \&change_elements_colors, 1],
	
	'Change arrow direction' => ['000-d', \&change_arrow_direction],
	'Flip arrow start and end' => ['000-f', \&flip_arrow_ends],
	) ;
	
#----------------------------------------------------------------------------------------------

sub change_elements_colors
{
my ($self, $is_background) = @_ ;

my ($color) = $self->get_color_from_user([0, 0, 0]) ;

$self->create_undo_snapshot() ;

for my $element($self->get_selected_elements(1))
	{
	$is_background
		? $element->set_background_color($color) 
		: $element->set_foreground_color($color) ;
		
	}
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub flip_arrow_ends
{
my ($self) = @_ ;

my @elements_to_flip=  
	grep 
		{
		my @connectors = $_->get_connector_points() ; 
		ref $_ eq 'App::Asciio::stripes::wirl_arrow' && @connectors > 0 ;
		} $self->get_selected_elements(1) ;

if(@elements_to_flip)
	{
	$self->create_undo_snapshot() ;
	
	my %reverse_direction = 
		(
		'up', => 'down',
		'right' => 'left',
		'down' => 'up',
		'left' => 'right'
		) ;
		
	for (@elements_to_flip)
		{
		# create one with ends swapped
		my $new_direction = $_->{DIRECTION} ;
		
		if($new_direction =~ /(.*)-(.*)/)
			{
			my ($start_direction, $end_direction) = ($1, $2) ;
			$new_direction = $reverse_direction{$end_direction} . '-' . $reverse_direction{$start_direction} ;
			}
				
		use App::Asciio::stripes::wirl_arrow ;
		my $arrow = new App::Asciio::stripes::wirl_arrow
							({
							%{$_},
							END_X =>- $_->{END_X},
							END_Y => - $_->{END_Y},
							DIRECTION => $new_direction,
							}) ;
		
		#add new element, connects automatically
		$self->add_element_at($arrow, $_->{X} + $_->{END_X}, $_->{Y} + $_->{END_Y}) ;
		
		# remove element
		$self->delete_elements($_) ;
		
		# keep the element selected
		$self->select_elements(1, $arrow) ;
		}
		
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub change_arrow_direction
{
my ($self) = @_ ;

my @elements_to_redirect =  
	grep 
		{
		my @connectors = $_->get_connector_points() ; 
		ref $_ eq 'App::Asciio::stripes::wirl_arrow' && @connectors > 0 ;
		} $self->get_selected_elements(1) ;

if(@elements_to_redirect)
	{
	$self->create_undo_snapshot() ;
	
	for (@elements_to_redirect)
		{
		my $direction = $_->get_section_direction() ;
		
		if($direction =~ /(.*)-(.*)/)
			{
			$_->resize(0, 0, 0, 0, "$2-$1") ;
			}
		}
		
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub select_next_element
{
my ($self) = @_ ;

return unless exists $self->{ELEMENTS}[0] ;

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;

if(@selected_elements)
	{
	my $last_selected_element = $selected_elements[-1] ;
	
	my ($seen_selected, $next_element) ;
	
	for my $element (@{$self->{ELEMENTS}}) 
		{
		if(! $self->is_element_selected($element) && $seen_selected)
			{
			$next_element = $element ; last ;
			}
			
		$seen_selected =$element == $last_selected_element ;
		}
		
	$self->select_elements(0, @{$self->{ELEMENTS}}) ;
	
	if($next_element)
		{
		$self->select_elements(1, $next_element) ;
		}
	else
		{
		$self->select_elements(1, $self->{ELEMENTS}[0]);
		}
	}
else
	{
	$self->select_elements(1, $self->{ELEMENTS}[0]);
	}
	
$self->update_display() ;
}

 #----------------------------------------------------------------------------------------------

sub select_previous_element
{
my ($self) = @_ ;

return unless exists $self->{ELEMENTS}[0] ;

$self->create_undo_snapshot() ;

my @selected_elements = $self->get_selected_elements(1) ;
if(@selected_elements)
	{
	my $last_selected_element = $selected_elements[0]  ;

	my ($seen_selected, $next_element) ;
	for my $element (reverse @{$self->{ELEMENTS}}) 
		{
		if(! $self->is_element_selected($element) && $seen_selected)
			{
			$next_element = $element ; last ;
			}
			
		$seen_selected =$element == $last_selected_element ;
		}
		
	$self->select_elements(0, @{$self->{ELEMENTS}}) ;

	 if(defined $next_element)
		{
		$self->select_elements(1, $next_element) ;
		}
	else
		{
		$self->select_elements(1, $self->{ELEMENTS}[-1]);
		}
	}
else
	{
	$self->select_elements(1, $self->{ELEMENTS}[-1]);
	}
	
$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub select_all_elements
{
my ($self) = @_ ;

$self->select_elements(1, @{$self->{ELEMENTS}}) ;
$self->update_display() ;
} ;	
	
#----------------------------------------------------------------------------------------------

sub delete_selected_elements
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->delete_elements($self->get_selected_elements(1)) ;
$self->update_display() ;
} ;	

#----------------------------------------------------------------------------------------------

sub move_selection_left
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->move_elements(-1, 0, $self->get_selected_elements(1)) ;
$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub move_selection_right
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->move_elements(1, 0, $self->get_selected_elements(1)) ;
$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub move_selection_up
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->move_elements(0, -1, $self->get_selected_elements(1)) ;
$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub move_selection_down
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

$self->move_elements(0, 1, $self->get_selected_elements(1)) ;
$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub group_selected_elements
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements >= 2)
	{
	$self->create_undo_snapshot() ;
	
	my $group = {'GROUP_COLOR' => $self->get_group_color()} ;
	for my $element (@selected_elements)
		{
		push @{$element->{'GROUP'}}, $group  ;
		}
	}
	
$self->update_display() ;
} ;


#----------------------------------------------------------------------------------------------

sub ungroup_selected_elements
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

for my $grouped (grep {exists $_->{GROUP} } @selected_elements)
	{
	pop @{$grouped->{GROUP}} ;
	}

$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub move_selected_elements_to_front
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements)
	{
	$self->create_undo_snapshot() ;
	$self->move_elements_to_front(@selected_elements) ;
	}
	
$self->update_display() ;
} ;

#----------------------------------------------------------------------------------------------

sub move_selected_elements_to_back
{
my ($self) = @_ ;

my @selected_elements = $self->get_selected_elements(1)  ;

if(@selected_elements)
	{
	$self->create_undo_snapshot() ;
	$self->move_elements_to_back(@selected_elements) ;
	}
	
$self->update_display() ;
} ;
