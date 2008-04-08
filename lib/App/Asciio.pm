
package App::Asciio ;

$|++ ;

use strict;
use warnings;

use Data::TreeDumper ;
use Clone;
use List::Util qw(min max first) ;
use List::MoreUtils qw(any minmax first_value) ;

use Glib ':constants';
use Gtk2 -init;
use Gtk2::Gdk::Keysyms ;
my %K = %Gtk2::Gdk::Keysyms ;
my %C = map{$K{$_} => $_} keys %K ;


use App::Asciio::Setup ;
use App::Asciio::Dialogs ;
use App::Asciio::Elements ;
use App::Asciio::Menues ;
use App::Asciio::Actions ;
use App::Asciio::Undo ;
use App::Asciio::Io ;
use App::Asciio::Ascii ;

#-----------------------------------------------------------------------------

our $VERSION = '0.94' ;

#-----------------------------------------------------------------------------

=head1 NAME 

 Asciio - Plain ASCII diagram

	                  |     |             |       |
	          |       |     |      |      |       |
	          |       |     |      |      |       |
	          v       |     v      |      v       |
	                  v            v              v
		 ______                          _____      
		/\  _  \                  __  __/\  __`\    
		\ \ \L\ \    ____    ___ /\_\/\_\ \ \/\ \   
	----->	 \ \  __ \  /',__\  /'___\/\ \/\ \ \ \ \ \  ----->
		  \ \ \/\ \/\__, `\/\ \__/\ \ \ \ \ \ \_\ \ 
		   \ \_\ \_\/\____/\ \____\\ \_\ \_\ \_____\
		    \/_/\/_/\/___/  \/____/ \/_/\/_/\/_____/
	
	          |             |             |     |
	          |     |       |     |       |     |      |
	          v     |       |     |       v     |      |
		        |       v     |             |      |
		        v             |             |      v
		       		      v             v
	(\_/)
	(O.o) ASCII world domination is near!
	(> <) 

=head1 SYNOPSIS

	$> perl asciio.pl

=head1 DESCRIPTION

This gtk2-perl application allows you to draw ASCII diagrams in a modern (but simple) graphical
application. The ASCII graphs can be saved as ASCII or in a format that allows you to modify them later.

Thanks to all the Perl-QA hackathon 2008 in Oslo for pushing me to do an early release.

Special thanks go to Gábor Szabó for his help and advices. Adam Kennedy coined the cool name.

Sometimes a diagram is worth a lot of text in a source code file. It has always been painfull to do 
ASCII diagrams by hand. The simple example below comes from a module I wrote a few years ago. I remember
cursing a few times then I tried to draw the graph in a program made for non ASCII diagrams and convert
the XML output to ASCII. That still didn't work so nicely. A diagram as simple as the one below can take a 
lot of time, specially if you have to modify it.

=head1 DOCUMENTATION

=head2 asciio user interface

	
          default elements in an empty diagram
                    .------------------------.
                    |               |        |
                    |               |        |
            .-------|---------------|--------|------------------------------------------.
            |       |               |        |  asciio                                  |
            |-------|---------------|--------|------------------------------------------|
            | ......v---------......v........v......................................... |
            | .....|          |..edit_me....--->....................................... |
            | .....'----------'........................................................ |
            | ......................................................................... |
            | ...................----------------..---------------..................... |
            | ..................| ASCII        > || thin_box      |.................... |
            | ..................| Rules line   > || text          |.................... |
            | ..................| Load           || wirl_arrow    |.................... |
    grid------------->..........| Save           || arrow         |.----------......... |
            | ..................| Export       > || box         > || star_box |........ |
            | ..................'----------------'| Rulers      > |'----------'........ |
            | ...........................^........| Misc        > |.................... |
            | ...........................|........| T_star        |.................... |
            | ...........................|........'---------------'.................... |
            | ...........................|............................................. |
            | ...........................|............................................. |
            | ...........................|............................................. |
            | ...........................|............................................. |
            | ...........................|............................................. |
            | ...........................|............................................. |
            '----------------------------|----------------------------------------------'
                                         |
                                   context menu
				   

=head2 context menu

The context menu allows to access to B<asciio> commands. B<ASCII> is used to insert ASCII elements.

=head2 keyboard shortcuts

All the keyboad commands definitions can be found under I<asciio/setup/actions/>. Among the commands
implemented are:

=over 2

=item * select all

=item * delete

=item * undo

=item * group/ungroup

=item * open / save

=item * local clipboard operations

=back

A window displaying the currently aailable commands is displayed if you press B<CTL+K>.

=head2 elements

There but a few elements implemented at the moment.

=head3 wirl arrow

An arrow that tries to do what you want. Try rotating the end clockwise then counter clockwise to see how it acts

               ^
               |
               |    --------.
               |            |
               '-------     |
                            |
 O-------------X     /      |
                    /       |
                   /        |
                  /         v
                 /
                /
               v

=head3 box and text 

Both are implemented within the same code. Try double clicking on a box to see what you can do with it.

                 .----------.
                 |  title   |
  .----------.   |----------|   ************
  |          |   | body 1   |   *          *
  '----------'   | body 2   |   ************
                 '----------'
                                             anything in a box
                                 (\_/)               |
         edit_me                 (O.o)  <------------'
                                 (> <)

=head3 your own element type

For simple elemnts, put your design in a box. that should cover 90% of anyone's needs. You can look in 
I<lib/stripes> for element implementation examples.

=head2 exporting to ASCII

In the context menu un I<Export>, you can export to a file in ASCII format but using the B<.txt> extension.

=head1 TODO

There is much to be done. I didn't think I'd spend so much time writting B<asciio> to start with and I can see it's going to take 
much more work. Still it's quite usable for a quick application. You are very welcome to give me feedback and even join in the
development of B<asciio>. For Christmas(tm), I'll iron out the last problems and do some refactoring. I'll then add support for 
externally defined routing mechanisms and will work on a wirl arrow that has more than two segments.

=head1 EXAMPLES

	
           User code ^            ^ OS code
                      \          /
                       \        /
                        \      /
           User code <----Mode----->OS code
                        /      \
                       /        \
                      /          \
          User code  v            v OS code
	  


	
	     .---.  .---. .---.  .---.    .---.  .---.
    OS API   '---'  '---' '---'  '---'    '---'  '---'
               |      |     |      |        |      |
               v      v     |      v        |      v
             .------------. | .-----------. |  .-----.
             | Filesystem | | | Scheduler | |  | MMU |
             '------------' | '-----------' |  '-----'
                    |       |      |        |
                    v       |      |        v
                 .----.     |      |    .---------.
                 | IO |<----'      |    | Network |
                 '----'            |    '---------'
                    |              |         |
                    v              v         v
             .---------------------------------------.
             |                  HAL                  |
             '---------------------------------------'
	     


                 
		 .---------.  .---------.
                 | State 1 |  | State 2 |
                 '---------'  '---------'
                    ^   \         ^  \
                   /     \       /    \
                  /       \     /      \
                 /         \   /        \
                /           \ /          \
               /             v            v
            ******        ******        ******
            * T1 *        * T2 *        * T3 *
            ******        ******        ******
               ^             ^             /
                \             \           /
                 \             \         /
                  \             \       / stimuli
                   \             \     /
                    \             \   v
                     \         .---------.
                      '--------| State 3 |
                               '---------'
			       

=cut

sub new
{
my ($class, $width, $height) = @_ ;

my $drawing_area = Gtk2::DrawingArea->new;

my $self = 
	bless 
		{
		widget => $drawing_area,
		ELEMENT_TYPES => [],
		ELEMENTS => [],
		CONNECTIONS => [],
		CLIPBOARD => {},
		FONT_FAMILY => 'Monospace',
		FONT_SIZE => '10',
		TAB_AS_SPACES => '   ',
		OPAQUE_ELEMENTS => 1,
		
		PREVIOUS_X => -1, PREVIOUS_Y => -1,
		MOUSE_X => 0, MOUSE_Y => 0,
		DRAGGING => '',
		SELECTION_RECTANGLE =>{START_X => 0, START_Y => 0},
		
		ACTIONS => {},
		VALID_SELECT_ACTION => { map {$_, 1} qw(resize move)},
		
		COPY_OFFSET_X => 3,
		COPY_OFFSET_Y => 3,
		COLORS =>
			{
			background => [255, 255, 255],
			grid => [229, 235, 255],
			ruler_line => [85, 155, 225],
			selected_element_background => [180, 244, 255],
			element_background => [251, 251, 254],
			element_foreground => [0, 0, 0] ,
			selection_rectangle => [255, 0, 255],
			test => [0, 255, 255],
			
			group_colors =>
				[
				[[250, 221, 190], [250, 245, 239]],
				[[182, 250, 182], [241, 250, 241]],
				[[185, 219, 250], [244, 247, 250]],
				[[137, 250, 250], [235, 250, 250]],
				[[198, 229, 198], [239, 243, 239]],
				],
				
			connection => 'Chocolate',
			connection_point => [230, 198, 133],
			connector_point => 'DodgerBlue',
			extra_point => [230, 198, 133],
			},
		
		NEXT_GROUP_COLOR => 0, 
		GROUP_COLORS  => [0 .. 4] ,
			
		WORK_DIRECTORY => '.asciio_work_dir',
		CREATE_BACKUP => 1,
		MODIFIED => 0,
		
		DO_STACK_POINTER => 0,
		DO_STACK => [] ,
		}, __PACKAGE__ ;

$self->{CURRENT_ACTIONS} = $self->{ACTIONS}  ;

$drawing_area->can_focus(TRUE) ;
$self->set_font($self->{FONT_FAMILY}, $self->{FONT_SIZE});

$drawing_area->signal_connect(configure_event => \&configure_event, $self);
$drawing_area->signal_connect(expose_event => \&expose_event, $self);
$drawing_area->signal_connect(motion_notify_event => \&motion_notify_event, $self);
$drawing_area->signal_connect(button_press_event => \&button_press_event, $self);
$drawing_area->signal_connect(button_release_event => \&button_release_event, $self);
$drawing_area->signal_connect(key_press_event => \&key_press_event, $self);

$drawing_area->set_events
		([qw/
		exposure-mask
		leave-notify-mask
		button-press-mask
		button-release-mask
		pointer-motion-mask
		key-press-mask
		key-release-mask
		/]);

return($self) ;
}

#-----------------------------------------------------------------------------

sub set_title
{
my ($self, $title) = @_;

if(defined $title)
	{
	$self->{widget}->get_toplevel()->set_title($title . ' - asciio') ;
	$self->{TITLE} = $title ;
	}
}

sub get_title
{
my ($self) = @_;
$self->{TITLE} ;
}

#-----------------------------------------------------------------------------

sub set_font
{
my ($self, $font_family, $font_size) = @_;

$self->{FONT_FAMILY} = $font_family || 'Monospace';
$self->{FONT_SIZE} = $font_size || 10 ;

$self->{widget}->modify_font
	(
	Gtk2::Pango::FontDescription->from_string 
		(
		$self->{FONT_FAMILY} . ' ' . $self->{FONT_SIZE}
		)
	);
}

sub get_font
{
my ($self) = @_;

return($self->{FONT_FAMILY},  $self->{FONT_SIZE}) ;
}

#-----------------------------------------------------------------------------

sub update_display 
{
my ($self) = @_;
my $widget = $self->{widget} ;

$self->call_hook('CANONIZE_CONNECTIONS', $self->{CONNECTIONS}, $self->get_character_size()) ;

$widget->queue_draw_area(0, 0, $widget->allocation->width,$widget->allocation->height);
}

#-----------------------------------------------------------------------------

sub call_hook
{
my ($self, $hook_name,  @arguments) = @_;

$self->{HOOKS}{$hook_name}->(@arguments)  if (exists $self->{HOOKS}{$hook_name}) ;
}

#-----------------------------------------------------------------------------

sub configure_event 
{
my ($widget, $event, $self) = @_;

$self->{PIXMAP} = Gtk2::Gdk::Pixmap->new 
			(
			$widget->window,
			$widget->allocation->width, $widget->allocation->height,
			-1
			);

$self->{PIXMAP}->draw_rectangle
		(
		$widget->get_style->base_gc ($widget->state),
		TRUE, 0, 0, $widget->allocation->width,
		$widget->allocation->height
		);
		
return TRUE;
}

#-----------------------------------------------------------------------------

sub expose_event
{
my ($widget, $event, $self) = @_;

my $gc = Gtk2::Gdk::GC->new($self->{PIXMAP});

# draw background
$gc->set_foreground($self->get_color('background'));

$self->{PIXMAP}->draw_rectangle
		(
		$gc,	TRUE,
		0, 0,
		$widget->allocation->width, $widget->allocation->height
		);

my ($character_width, $character_height) = $self->get_character_size() ;
my ($widget_width, $widget_height) = $self->{PIXMAP}->get_size();

# draw grid
$gc->set_foreground($self->get_color('grid'));

for my $horizontal (0 .. ($widget_height/$character_height) + 1)
	{
	$self->{PIXMAP}->draw_line
				(
				$gc,
				0,  $horizontal * $character_height,
				$widget_width, $horizontal * $character_height
				);
	}

for my $vertical(0 .. ($widget_width/$character_width) + 1)
	{
	$self->{PIXMAP}->draw_line
				(
				$gc,
				$vertical * $character_width, 0,
				$vertical * $character_width, $widget_height
				);
	}

# draw elements
for my $element (@{$self->{ELEMENTS}})
	{
	my ($background_color, $foreground_color) =  $element->get_colors() ;
	
	$background_color = 
		defined $background_color
			? $self->get_color($background_color)
			: $self->get_color('element_background') ;
		
	$foreground_color = 
		defined $foreground_color
			? $self->get_color($foreground_color)
			: $self->get_color('element_foreground') ;
			
	if($self->is_element_selected($element))
		{
		if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
			{
			$background_color = 
				$self->get_color
					(
					$self->{COLORS}{group_colors}[$element->{GROUP}[-1]{GROUP_COLOR}][0]
					) ;
			}
		else
			{
			$background_color = $self->get_color('selected_element_background');
			}
		}
	else
		{
		if(exists $element->{GROUP} and defined $element->{GROUP}[-1])
			{
			$background_color = 
				$self->get_color
					(
					$self->{COLORS}{group_colors}[$element->{GROUP}[-1]{GROUP_COLOR}][1]
					) ;
			}
		}
			
	$gc->set_foreground($foreground_color);
	
	for my $mask_and_element_strip ($element->get_mask_and_element_stripes())
		{
		$gc->set_foreground($background_color);
			
		$self->{PIXMAP}->draw_rectangle
					(
					$gc,
					$self->{OPAQUE_ELEMENTS},
					($element->{X} + $mask_and_element_strip->{X_OFFSET}) * $character_width,
					($element->{Y} + $mask_and_element_strip->{Y_OFFSET}) * $character_height,
					$mask_and_element_strip->{WIDTH} * $character_width,
					$mask_and_element_strip->{HEIGHT} * $character_height,
					);
					
		$gc->set_foreground($foreground_color);
		
		my $layout = $widget->create_pango_layout($mask_and_element_strip->{TEXT}) ;
		
		my ($text_width, $text_height) = $layout->get_pixel_size;
		
		$self->{PIXMAP}->draw_layout
					(
					$gc,
					($element->{X} + $mask_and_element_strip->{X_OFFSET}) * $character_width,
					($element->{Y} + $mask_and_element_strip->{Y_OFFSET}) * $character_height,
					$layout
					);
		}
	}

# draw ruler lines
for my $line (@{$self->{RULER_LINES}})
	{
	my $color = Gtk2::Gdk::Color->new( map {$_ * 257} @{$line->{COLOR} }) ;
	$self->{widget}->get_colormap->alloc_color($color,TRUE,TRUE) ;
	
	$gc->set_foreground($color);
	
	if($line->{TYPE} eq 'VERTICAL')
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					$line->{POSITION} * $character_width, 0,
					$line->{POSITION} * $character_width, $widget_height
					);
		}
	else
		{
		$self->{PIXMAP}->draw_line
					(
					$gc,
					0, $line->{POSITION} * $character_height,
					$widget_width, $line->{POSITION} * $character_height
					);
		}
	}

# draw connections
my (%connected_connections, %connected_connectors) ;

for my $connection (@{$self->{CONNECTIONS}})
	{
	my $draw_connection ;
	my $connector  ;
	
	if($self->is_over_element($connection->{CONNECTED}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		$connector = $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		$connected_connectors{$connection->{CONNECTED}}{$connector->{X}}{$connector->{Y}}++ ;
		}
		
	if($self->is_over_element($connection->{CONNECTEE}, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1))
		{
		$draw_connection++ ;
		
		my $connectee_connection = $connection->{CONNECTEE}->get_named_connection($connection->{CONNECTION}{NAME}) ;
		$connected_connectors{$connection->{CONNECTEE}}{$connectee_connection->{X}}{$connectee_connection->{Y}}++ ;
		}
		
	if($draw_connection)
		{
		$gc->set_foreground($self->get_color('connection'));	
		
		$connector ||= $connection->{CONNECTED}->get_named_connection($connection->{CONNECTOR}{NAME}) ;
		
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						($connector->{X} + $connection->{CONNECTED}{X}) * $character_width,
						($connector->{Y}  + $connection->{CONNECTED}{Y}) * $character_height,
						$character_width, $character_height
						);
		}
	}
	
# draw connectors and connection points
for my $element (grep {$self->is_over_element($_, $self->{MOUSE_X}, $self->{MOUSE_Y}, 1)} @{$self->{ELEMENTS}})
	{
	$gc->set_foreground($self->get_color('connector_point'));
	for my $connector ($element->get_connector_points())
		{
		next if exists $connected_connectors{$element}{$connector->{X}}{$connector->{Y}} ;
		
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						($element->{X} + $connector->{X}) * $character_width,
						($connector->{Y} + $element->{Y}) * $character_height,
						$character_width, $character_height
						);
		}
		
	$gc->set_foreground($self->get_color('connection_point'));
	for my $connection_point ($element->get_connection_points())
		{
		next if exists $connected_connections{$element}{$connection_point->{X}}{$connection_point->{Y}} ;
		
		$self->{PIXMAP}->draw_rectangle # little box
						(
						$gc,
						TRUE,
						(($connection_point->{X} + $element->{X}) * $character_width) + ($character_width / 3),
						(($connection_point->{Y} + $element->{Y}) * $character_height) + ($character_height / 3),
						$character_width / 3 , $character_height / 3
						);
		}
		
	for my $extra_point ($element->get_extra_points())
		{
		if(exists $extra_point ->{COLOR})
			{
			$gc->set_foreground($self->get_color($extra_point ->{COLOR}));
			}
		else
			{
			$gc->set_foreground($self->get_color('extra_point'));
			}
			
		$self->{PIXMAP}->draw_rectangle
						(
						$gc,
						FALSE,
						(($extra_point ->{X}  + $element->{X}) * $character_width),
						(($extra_point ->{Y}  + $element->{Y}) * $character_height),
						$character_width, $character_height 
						);
		}
	}

# draw new connections
for my $new_connection (@{$self->{NEW_CONNECTIONS}})
	{
	$gc->set_foreground($self->get_color('red'));
	
	my $end_connection = $new_connection->{CONNECTED}->get_named_connection($new_connection->{CONNECTOR}{NAME}) ;
	
	$self->{PIXMAP}->draw_rectangle
					(
					$gc,
					FALSE,
					($end_connection->{X} + $new_connection->{CONNECTED}{X}) * $character_width ,
					($end_connection->{Y} + $new_connection->{CONNECTED}{Y}) * $character_height ,
					$character_width, $character_height
					);
	}

delete $self->{NEW_CONNECTIONS} ;
	
# draw selection rectangle
if(defined $self->{SELECTION_RECTANGLE}{END_X})
	{
	my $start_x = $self->{SELECTION_RECTANGLE}{START_X} * $character_width ;
	my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} * $character_height ;
	my $width = ($self->{SELECTION_RECTANGLE}{END_X} - $self->{SELECTION_RECTANGLE}{START_X}) * $character_width ;
	my $height = ($self->{SELECTION_RECTANGLE}{END_Y} - $self->{SELECTION_RECTANGLE}{START_Y}) * $character_height; 
	
	if($width < 0)
		{
		$width *= -1 ;
		$start_x -= $width ;
		}
		
	if($height < 0)
		{
		$height *= -1 ;
		$start_y -= $height ;
		}
		
	$gc->set_foreground($self->get_color('selection_rectangle')) ;
	$self->{PIXMAP}->draw_rectangle($gc, FALSE,$start_x, $start_y, $width, $height);
	
	delete $self->{SELECTION_RECTANGLE}{END_X} ;
	}

$widget->window->draw_drawable
		(
		$widget->style->fg_gc($widget->state),
		$self->{PIXMAP},
		$event->area->x, $event->area->y,
		$event->area->x, $event->area->y,
		$event->area->width, $event->area->height
		);

return TRUE;
}

#-----------------------------------------------------------------------------

sub button_release_event 
{
my ($widget, $event, $self) = @_ ;

my $modifiers = get_key_modifiers($event) ;

if($self->exists_action("${modifiers}-button_release"))
	{
	$self->run_actions(["${modifiers}-button_release", $event]) ;
	return TRUE ;
	}

if($self->{MODIFIED_INDEX} == $self->{MODIFIED})
	{
	$self->pop_undo_buffer(1) ; # no changes
	}

$self->update_display();
}

#-----------------------------------------------------------------------------

sub button_press_event 
{
#~ print "button_press_event\n" ;
my ($widget, $event, $self) = @_ ;

$self->{DRAGGING} = '' ;
delete $self->{RESIZE_CONNECTOR_NAME} ;

$self->create_undo_snapshot() ;
$self->{MODIFIED_INDEX} = $self->{MODIFIED} ;

my $modifiers = get_key_modifiers($event) ;

if($self->exists_action("${modifiers}-button_press"))
	{
	$self->run_actions(["${modifiers}-button_press", $event]) ;
	return TRUE ;
	}

if($event->type eq '2button-press')
	{
	my($x, $y) = $self->closest_character($event->coords()) ;
	
	my @element_over = grep { $self->is_over_element($_, $x, $y) } reverse @{$self->{ELEMENTS}} ;
	
	if(@element_over)
		{
		
		my $selected_element = $element_over[0] ;
		
		$selected_element->edit() ;
		
		# handle connections
		if($self->is_connected($selected_element))
			{
			# disconnect current connections
			$self->delete_connections_containing($selected_element) ;
			}
			
		#~ !!! TODO if not already connected to them (same connection)
		$self->connect_elements($selected_element) ; # connect to new elements if any
		
		
		for my $connection ($self->get_connected($selected_element))
			{
			# all connection where the selected element is the connectee
			
			my ($new_connection) = # in characters relative to element origin
					$selected_element->get_named_connection($connection->{CONNECTION}{NAME}) ;
			
			if(defined $new_connection)
				{
				my ($x_offset, $y_offset, $width, $height, $new_connector) = 
					$connection->{CONNECTED}->move_connector
						(
						$connection->{CONNECTOR}{NAME},
						$new_connection->{X} - $connection->{CONNECTION}{X},
						$new_connection->{Y}- $connection->{CONNECTION}{Y}
						) ;
						
				$connection->{CONNECTED}{X} += $x_offset ;
				$connection->{CONNECTED}{Y} += $y_offset;
				
				# the connection point has also changed
				$connection->{CONNECTOR} = $new_connector ;
				$connection->{CONNECTION} = $new_connection ;
				
				$connection->{FIXED}++ ;
				
				#find the other connectors belonging to this connected
				for my $other_connection (grep{ ! $_->{FIXED}} @{$self->{CONNECTIONS}})
					{
					# move them relatively to their previous position
					if($connection->{CONNECTED} == $other_connection->{CONNECTED})
						{
						my ($new_connector) = # in characters relative to element origin
								$other_connection->{CONNECTED}->get_named_connection($other_connection->{CONNECTOR}{NAME}) ;
						
						$other_connection->{CONNECTOR} = $new_connector ;
						$other_connection->{FIXED}++ ;
						}
					}
					
				for my $connection (@{$self->{CONNECTIONS}})
					{
					delete $connection->{FIXED} ;
					}
				}
			else
				{
				$self->delete_connections($connection) ;
				}
				
			#~ TODO fix the other connection as move does above
			}
			
		$self->{MODIFIED }++ ;
		$self->update_display();
		}
		
	return TRUE ;
	}

if($event->button == 1) 
	{
	my $modifiers = get_key_modifiers($event) ;
	
	my ($x, $y) = $self->closest_character($event->coords()) ;
	my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @{$self->{ELEMENTS}} ;
	
	if ($modifiers eq 'C00')
		{
		if(defined $first_element)
			{
			$self->run_actions_by_name('Copy to clipboard', ['Insert from clipboard', 0, 0])  ;
			}
		}
	else
		{
		if(defined $first_element)
			{
			 if ($modifiers eq '00S')
				{
				$self->select_elements_flip($first_element) ;
				}
			else
				{
				unless($self->is_element_selected($first_element))
					{
					$self->select_elements(0, @{$self->{ELEMENTS}}) ;
					$self->select_elements(1, $first_element) ;
					}
				}
			}
		else
			{
			$self->select_elements(0, @{$self->{ELEMENTS}})  if ($modifiers eq '000')  ;
			}
		}
	
	$self->{SELECTION_RECTANGLE} = {START_X => $x , START_Y => $y} ;
	
	$self->update_display();
	}
	
if($event->button == 3) 
	{
	$self->display_popup_menu($event) ;
	}
  
return TRUE;
}

#-----------------------------------------------------------------------------

sub motion_notify_event 
{
my ($widget, $event, $self) = @_ ;

my ($x, $y) = $self->closest_character($event->coords()) ;
my $modifiers = get_key_modifiers($event) ;

if($self->exists_action("${modifiers}motion_notify"))
	{
	$self->run_actions(["${modifiers}-motion_notify", $event]) ;
	return TRUE ;
	}

if($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y)
	{
	($self->{MOUSE_X}, $self->{MOUSE_Y}) = ($x, $y) ;
	$self->update_display() ;
	}
	
if ($event->state >= "button1-mask") 
	{
	if($self->{DRAGGING} ne '')
		{
		if      ($self->{DRAGGING} eq 'move') { $self->move_elements_event($x, $y) ; }
		elsif ($self->{DRAGGING}eq 'resize') { $self->resize_element_event($x, $y) ; }
		elsif ($self->{DRAGGING}eq 'select') { $self->select_element_event($x, $y) ; }
		}
	else
		{
		my @selected_elements = $self->get_selected_elements(1) ;
		my ($first_element) = first_value {$self->is_over_element($_, $x, $y)} reverse @selected_elements ;
		
		if(@selected_elements > 1)
			{
			if(defined $first_element)
				{
				$self->{DRAGGING} = 'move' ;
				}
			else
				{
				$self->{DRAGGING} = 'select' ;
				}
			}
		else
			{
			if(defined $first_element)
				{
				$self->{DRAGGING} = $first_element->get_selection_action
									(
									$x - $first_element->{X},
									$y - $first_element->{Y},
									);
									
				$self->{DRAGGING} ='' unless exists $self->{VALID_SELECT_ACTION}{$self->{DRAGGING}} ;
				}
			else
				{
				$self->{DRAGGING} = 'select' ;
				}
			}
			
		($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
		}
	}

return TRUE;
}

#-----------------------------------------------------------------------------

sub select_element_event
{
my ($self, $x, $y) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;
	
if($x_offset != 0 || $y_offset != 0)
	{
	$self->{SELECTION_RECTANGLE}{END_X} = $x ;
	$self->{SELECTION_RECTANGLE}{END_Y} = $y ;
	
	$self->select_elements
		(
		1,
		grep # elements within selection rectangle
			{
			$self->element_completely_within_rectangle
				(
				$_,
				$self->{SELECTION_RECTANGLE},
				)
			} @{$self->{ELEMENTS}}
		)  ;
	
	$self->update_display();
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	}
}

#-----------------------------------------------------------------------------

sub move_elements_event
{
my ($self, $x, $y) = @_;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

if($x_offset != 0 || $y_offset != 0)
	{
	my @selected_elements = $self->get_selected_elements(1) ;
	
	$self->move_elements($x_offset, $y_offset, @selected_elements) ;
	$self->update_display();
	
	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	}
}

#-----------------------------------------------------------------------------

sub resize_element_event
{
my ($self, $x, $y) = @_ ;

my ($x_offset, $y_offset) = ($x - $self->{PREVIOUS_X},  $y - $self->{PREVIOUS_Y}) ;

if($x_offset != 0 || $y_offset != 0)
	{
	my ($selected_element) = $self->get_selected_elements(1) ;
	
	$self->{RESIZE_CONNECTOR_NAME} =
		$self->resize_element
				(
				$self->{PREVIOUS_X} - $selected_element->{X}, $self->{PREVIOUS_Y} - $selected_element->{Y} ,
				$x - $selected_element->{X}, $y - $selected_element->{Y} ,
				$selected_element,
				$self->{RESIZE_CONNECTOR_NAME},
				) ;
				
	$self->update_display();

	($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($x, $y) ;
	}
}
	
#-----------------------------------------------------------------------------

sub key_press_event
{
my ($widget, $event, $self)= @_;

#~ print DumpTree \@_, '',  DISPLAY_PERL_ADDRESS => 1 ;
#~ print "key_press_event: keyval is <" . $event->keyval() . ">\n" ;

my $key = $C{$event->keyval()} ;
my $modifiers = get_key_modifiers($event) ;

$self->run_actions("$modifiers-$key") ;

return FALSE;
}

=head1 DEPENDENCIES

gnome libraries, gtk, gtk-perl, perl

=head1 BUGS AND LIMITATIONS

Undoubtedly many as I wrote this as a fun little project where I used no design nor 'methodic' whatsoever.

=head1 AUTHOR

	Khemir Nadim ibn Hamouda
	CPAN ID: NKH
	mailto:nadim@khemir.net

=head1 LICENSE AND COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

	http://www.jave.de
	http://search.cpan.org/~osfameron/Text-JavE-0.0.2/JavE.pm
	http://ditaa.sourceforge.net/
	http://www.codeproject.com/KB/macros/codeplotter.aspx
	http://search.cpan.org/~jpierce/Text-FIGlet-1.06/FIGlet.pm
	http://www.fossildraw.com/?gclid=CLanxZXxoJECFRYYEAodnBS8Dg (doesn't always respond)

=cut

#------------------------------------------------------------------------------------------------------

1 ;

