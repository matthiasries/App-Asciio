
package App::Asciio::stripes::section_wirl_arrow ;
use base App::Asciio::stripes::stripes ;

use strict;
use warnings;

use List::Util qw(min max) ;
use Readonly ;
use Clone ;

use App::Asciio::stripes::wirl_arrow ;

#-----------------------------------------------------------------------------

# the idea is to reuse wirl arrow implementation as much as possible

#-----------------------------------------------------------------------------

Readonly my $DEFAULT_ARROW_TYPE =>
			[
			['origin', '', '*', '', '', '', 1],
			['up', '|', '|', '', '', '^', 1],
			['down', '|', '|', '', '', 'v', 1],
			['left', '-', '-', '', '', '<', 1],
			['upleft', '|', '|', '.', '-', '<', 1],
			['leftup', '-', '-', '\'', '|', '^', 1],
			['downleft', '|', '|', '\'', '-', '<', 1],
			['leftdown', '-', '-', '.', '|', 'v', 1],
			['right', '-', '-','', '', '>', 1],
			['upright', '|', '|', '.', '-', '>', 1],
			['rightup', '-', '-', '\'', '|', '^', 1],
			['downright', '|', '|', '\'', '-', '>', 1],
			['rightdown', '-', '-', '.', '|', 'v', 1],
			['45', '/', '/', '', '', '^', 1, ],
			['135', '\\', '\\', '', '', 'v', 1, ],
			['225', '/', '/', '', '', 'v', 1, ],
			['315', '\\', '\\', '', '', '^', 1, ],
			] ;
			
sub new
{
my ($class, $element_definition) = @_ ;

my $self = bless  {}, __PACKAGE__ ;
	
$self->setup
	(
	$element_definition->{ARROW_TYPE} || Clone::clone($DEFAULT_ARROW_TYPE),
	$element_definition->{POINTS},
	$element_definition->{DIRECTION},
	$element_definition->{ALLOW_DIAGONAL_LINES},
	$element_definition->{EDITABLE},
	) ;

return $self ;
}

#-----------------------------------------------------------------------------

sub setup
{
my ($self, $arrow_type, $points, $direction, $allow_diagonal_lines, $editable) = @_ ;

if('ARRAY' eq ref $points && @{$points} > 0)
	{
	my ($start_x, $start_y, $arrows) = (0, 0, []) ;
	
	my $points_offsets ;
	my $arrow_index = 0 ; # must have a numeric index or 'undo' won't work
	
	for my $point (@{$points})
		{
		my ($x, $y, $point_direction) = @{$point} ;
		
		my $arrow = new App::Asciio::stripes::wirl_arrow
					({
					ARROW_TYPE => $arrow_type,
					END_X => $x - $start_x,
					END_Y => $y - $start_y,
					DIRECTION => $point_direction || $direction,
					ALLOW_DIAGONAL_LINES => $allow_diagonal_lines,
					EDITABLE => $editable,
					}) ;
						
		$points_offsets->[$arrow_index++] = [$start_x, $start_y] ;
		
		push @{$arrows},  $arrow ;
		($start_x, $start_y) = ($x, $y) ;
		}
		
	$self->set
		(
		POINTS => $points, # remember setup value
		POINTS_OFFSETS => $points_offsets,
		ARROWS => $arrows,
		
		# keep data to allow section insertion later
		ARROW_TYPE => $arrow_type,
		DIRECTION => $direction,
		ALLOW_DIAGONAL_LINES => $allow_diagonal_lines,
		EDITABLE => $editable,
		) ;
		
	my ($width, $height) = $self->get_width_and_height() ;
	$self->set
			(
			WIDTH => $width,
			HEIGHT => $height,
			) ;
	}
else
	{
	die 'bad defintion!' ;
	}
}

#-----------------------------------------------------------------------------
	
sub get_mask_and_element_stripes
{
my ($self) = @_ ;

my @mask_and_element_stripes ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	push @mask_and_element_stripes, 
		map 
		{
		$_->{X_OFFSET} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
		$_->{Y_OFFSET} += $self->{POINTS_OFFSETS}[$arrow_index][1];
		$_ ;
		} $arrow->get_mask_and_element_stripes() ;
		
	$arrow_index++ ;
	}

# handle connections
my ($previous_direction) = ($self->{ARROWS}[0]{DIRECTION} =~ /^([^-]+)-/) ;
$previous_direction ||= $self->{ARROWS}[0]{DIRECTION} ;

$arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($d1, $d2) ;
	
	unless(($d1, $d2) = ($arrow->{DIRECTION} =~ /^([^-]+)-(.*)$/)) 
		{
		$d1 = $arrow->{DIRECTION};
		}
	
	if($previous_direction ne $d1)
		{
		# overlay start 
		my $connection = '-' ; # for left and right, up down cases handled below
		
		if($d1 eq 'down')
			{
			$connection = q{.} ;
			}
		elsif($d1 eq 'up')
			{
			$connection = q{'} ;
			}
		elsif($previous_direction eq 'down')
			{
			$connection = q{'} ;
			}
		elsif($previous_direction eq 'up')
			{
			$connection = q{.} ;
			}
		
		push @mask_and_element_stripes, 
			{
			X_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][0],
			Y_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][1],
			WIDTH => 1,
			HEIGHT => 1,
			TEXT => $connection,
			} ;
		}
	elsif($arrow_index != 0)
		{
		# overlay start 
		my $connection = '-' ; # for left and right, up down cases handled below
		
		if($d1 eq 'down' || $d1 eq 'up')
			{
			$connection = q{|} ;
			}
		
		push @mask_and_element_stripes, 
			{
			X_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][0],
			Y_OFFSET => $self->{POINTS_OFFSETS}[$arrow_index][1],
			WIDTH => 1,
			HEIGHT => 1,
			TEXT => $connection,
			} ;
		}
		
	$previous_direction = defined $d2 ? $d2 : $d1 ;
	$arrow_index++ ;
	}

return(@mask_and_element_stripes) ;
}

#-----------------------------------------------------------------------------

sub get_selection_action
{
my ($self, $x, $y) = @_ ;

my $action = 'move' ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
		
	if($x == $start_connector->{X} && $y == $start_connector->{Y})
		{
		$action = 'resize' ;
		last ;
		}
		
	$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
	
	if($x == $end_connector->{X} && $y == $end_connector->{Y})
		{
		$action = 'resize' ;
		last ;
		}
		
	$arrow_index++ ;
	}

return $action ;
}

#-----------------------------------------------------------------------------

sub get_connector_points
{
my ($self) = @_ ;

my(@connector_points)  = $self->get_all_points() ;
return($connector_points[0], $connector_points[-1]) ;
}

sub get_extra_points
{
my ($self) = @_ ;

my(@connector_points)  = $self->get_all_points() ;
shift @connector_points ;
pop @connector_points ;

return(@connector_points) ;
}

sub get_all_points
{
my ($self) = @_ ;

my(@connector_points) ;

my $arrow_index = 0 ;

for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($arrow == $self->{ARROWS}[0])
		{
		$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
		$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
		$start_connector->{NAME} .= "section_$arrow_index" ;
		
		push @connector_points, $start_connector ;
		}
		
	$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
	$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
	$end_connector->{NAME} .= "section_$arrow_index" ;
	
	push @connector_points, $end_connector ;
	$arrow_index++ ;
	}

return(@connector_points) ;
}

#-----------------------------------------------------------------------------

sub get_named_connection
{
my ($self, $name) = @_ ;

my $connection ;

my $arrow_index = 0 ;

for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($arrow == $self->{ARROWS}[0])
		{
		$start_connector->{NAME} .= "section_$arrow_index" ;
		
		if($name eq  $start_connector->{NAME})
			{
			$start_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
			$start_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
			$connection = $start_connector ;
			last ;
			}
		}
		
	$end_connector->{NAME} .= "section_$arrow_index" ;
	
	if($name eq  $end_connector->{NAME})
		{
		$end_connector->{X} += $self->{POINTS_OFFSETS}[$arrow_index][0] ;
		$end_connector->{Y} += $self->{POINTS_OFFSETS}[$arrow_index][1] ;
		$connection = $end_connector ;
		last ;
		}
		
	$arrow_index++ ;
	}

return $connection ;
}

#-----------------------------------------------------------------------------

sub move_connector
{
my ($self, $connector_name, $x_offset, $y_offset, $hint) = @_ ;

my $connection = $self->get_named_connection($connector_name) ;

if($connection)
	{
	my ($x_offset, $y_offset, $width, $height, undef) = 
		$self->resize
			(
			$connection->{X},
			$connection->{Y},
			$connection->{X} + $x_offset,
			$connection->{Y} + $y_offset,
			$hint,
			) ;
		
	return
		(
		$x_offset, $y_offset, $width, $height,
		$self->get_named_connection($connector_name)
		) ;
	}
else
	{
	die "unknown connector '$connector_name'!\n" ;
	}
}

#-----------------------------------------------------------------------------

sub resize
{
my ($self, $reference_x, $reference_y, $new_x, $new_y, $hint, $connector_name_array) = @_ ;

Readonly my $MULTI_WIRL_CONNECTOR_NAME_INDEX => 0 ;
Readonly my $WIRL_CONNECTOR_NAME_INDEX => 1 ;

my ($start_element, $start_element_index, $end_element, $end_element_index) ;

# find elements connected by the connector
if(defined $connector_name_array)
	{
	($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) = 
		$self->find_elements_for_connector_named($connector_name_array) ;
	}
else
	{
	($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) = 
		$self->find_elements_for_connector_at($reference_x, $reference_y) ;
	}

my ($start_x_offset, $start_y_offset) = (0, 0) ;
if(defined $start_element)
	{
	my $is_start ;
	if(defined $connector_name_array)
		{
		$is_start++ if($connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX] eq 'start') ;
		}
	else
		{
		$is_start++  if($reference_x == 0 && $reference_y == 0) ;
		}

	if($is_start)
		{
		# moving start connector
		
		($start_x_offset, $start_y_offset) = 
			$start_element->resize
				(
				0, 0,
				$new_x, $new_y,
				undef, # hint
				$connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX]
				) ;
		
		my $arrow_index = 0 ;
		for my $arrow(@{$self->{ARROWS}})
			{
			# offsets all other wirl_arrow start offsets
			if($arrow == $start_element)
				{
				}
			else
				{
				$self->{POINTS_OFFSETS}[$arrow_index][0] -= $start_x_offset ;
				$self->{POINTS_OFFSETS}[$arrow_index][1] -= $start_y_offset ;
				}
				
			$arrow_index++ ;
			}
		}
	else
		{
		my $start_element_x_offset = $self->{POINTS_OFFSETS}[$start_element_index][0] ;
		my $start_element_y_offset = $self->{POINTS_OFFSETS}[$start_element_index][1] ;

		my ($x_offset, $y_offset) = 
			$start_element ->resize
							(
							$reference_x - $start_element_x_offset,
							$reference_y - $start_element_y_offset,
							$new_x - $start_element_x_offset,
							$new_y - $start_element_y_offset,
							undef, # hint
							$connector_name_array->[$WIRL_CONNECTOR_NAME_INDEX]
							) ;
							
		$self->{POINTS_OFFSETS}[$start_element_index][0] += $x_offset ;
		$self->{POINTS_OFFSETS}[$start_element_index][1] += $y_offset ;
		
		if(defined $end_element)
			{
			my ($x_offset, $y_offset) = $end_element->resize(0, 0, $new_x - $reference_x, $new_y - $reference_y) ;
			$self->{POINTS_OFFSETS}[$end_element_index][0] += $x_offset ;
			$self->{POINTS_OFFSETS}[$end_element_index][1] += $y_offset ;
			}
		}
	}
	
my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height) ;

return($start_x_offset, $start_y_offset, $width, $height, $connector_name_array) ;
}

sub find_elements_for_connector_at
{
my ($self, $reference_x, $reference_y) = @_ ;
	
my ($start_element, $start_element_index, $end_element, $end_element_index, $connector_name, $wirl_connector_name) ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($reference_x == 0 && $reference_y == 0)
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		$wirl_connector_name = $start_connector->{NAME} ;
		$connector_name =  $wirl_connector_name . "section_$arrow_index" ;
		last ;
		}
		
	if(defined $start_element)
		{
		($end_element, $end_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
		
	if
		(
		   $reference_x == $end_connector->{X} + $self->{POINTS_OFFSETS}[$arrow_index][0]
		&& $reference_y == $end_connector->{Y} + $self->{POINTS_OFFSETS}[$arrow_index][1]
		)
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		$wirl_connector_name = $end_connector->{NAME} ;
		$connector_name =  $wirl_connector_name . "section_$arrow_index" ;
		}
		
	$arrow_index++ ;
	}

return($start_element, $start_element_index, $end_element, $end_element_index, [$connector_name, $wirl_connector_name])
}

sub find_elements_for_connector_named
{
my ($self, $connector_name_array) = @_ ;

my ($connector_name, $wirl_connector_name) = @{$connector_name_array} ;

my ($start_element, $start_element_index, $end_element, $end_element_index) ;

my $arrow_index = 0 ;
for my $arrow(@{$self->{ARROWS}})
	{
	my ($start_connector, $end_connector) = $arrow->get_connector_points() ;
	
	if($connector_name eq  $start_connector->{NAME} . "section_$arrow_index" )
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
		
	if(defined $start_element)
		{
		($end_element, $end_element_index) = ($arrow, $arrow_index) ;
		last ;
		}
		
	if($connector_name eq $end_connector->{NAME} . "section_$arrow_index")
		{
		($start_element, $start_element_index) = ($arrow, $arrow_index) ;
		}
		
	$arrow_index++ ;
	}
	
return($start_element, $start_element_index, $end_element, $end_element_index, $connector_name_array) ;
}

#-----------------------------------------------------------------------------

sub get_section_direction
{
my ($self, $section_index) = @_ ;

if(exists($self->{ARROWS}[$section_index]))
	{
	return $self->{ARROWS}[$section_index]{DIRECTION} ;
	}
else
	{
	return ;
	}
}

#-----------------------------------------------------------------------------

sub add_section
{
my ($self, $x, $y) = @_ ;

my $arrow = new App::Asciio::stripes::wirl_arrow
			({
			END_X => 6,
			END_Y => -6,
			ARROW_TYPE => $self->{ARROW_TYPE},
			DIRECTION => $self->{DIRECTION},
			ALLOW_DIAGONAL_LINES => $self->{ALLOW_DIAGONAL_LINES},
			EDITABLE => $self->{EDITABLE},
			}) ;

my ($start_x, $start_y) = @{$self->{POINTS_OFFSETS}[-1]} ;
my ($start_connector, $end_connector) = $self->{ARROWS}[-1]->get_connector_points() ;

$start_x += $end_connector->{X} ;
$start_y += $end_connector->{Y} ;

push @{$self->{POINTS_OFFSETS}}, [$start_x, $start_y] ;
push @{$self->{POINTS}}, [$start_x + 6, $start_y - 6] ;
push @{$self->{ARROWS}}, $arrow ;
		
my ($width, $height) = $self->get_width_and_height() ;
$self->set(WIDTH => $width, HEIGHT => $height,) ;
}

#-----------------------------------------------------------------------------

sub get_width_and_height
{
my ($self) = @_ ;

my ($smallest_x, $biggest_x, $smallest_y, $biggest_y) = (0, 0, 0, 0) ;

my $arrow_index = 0 ;
for my $start_point (@{$self->{POINTS_OFFSETS}})
	{
	my ($x, $y) = @{$start_point} ;
	
	my ($start_connector, $end_connector) = $self->{ARROWS}[$arrow_index]->get_connector_points() ;
	$x += $end_connector->{X} ;
	$y += $end_connector->{Y} ;
	
	$smallest_x = min($smallest_x, $x) ;
	$smallest_y = min($smallest_y, $y) ;
	$biggest_x = max($biggest_x, $x) ;
	$biggest_y = max($biggest_y, $y) ;
	
	$arrow_index++ ;
	}

return(($biggest_x - $smallest_x) + 1, ($biggest_y - $smallest_y) + 1) ;
}

#-----------------------------------------------------------------------------

sub edit
{
my ($self) = @_ ;

return unless $self->{EDITABLE} ;

# add section
# remove section

# handle offset array
}

#-----------------------------------------------------------------------------

1 ;









