
use List::Util qw(min max sum) ;

#----------------------------------------------------------------------------------------------

register_action_handlers
	(
	'Dump self' => ['CA0-d', \&dump_self],
	'Dump all elements' => ['C00-d', \&dump_all_elements],
	'Dump selected elements'=> ['C0S-D' , \&dump_selected_elements],
	'Test' => ['0A0-t',  \&test],
	) ;


#----------------------------------------------------------------------------------------------

sub dump_self
{
my ($self) = @_ ;

my $size = sum(map { length } @{$self->{DO_STACK}}) || 0 ;

local $self->{DO_STACK} = scalar(@{$self->{DO_STACK}})  . " [$size]";
	
#~ print Data::TreeDumper::DumpTree $self ;
$self->show_dump_window($self, 'asciio') ;
}

sub dump_selected_elements
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree [$self->get_selected_elements(1)] ;
$self->show_dump_window([$self->get_selected_elements(1)], 'asciio selected elements') ;
}

sub dump_all_elements
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree $self->{ELEMENTS} ;
$self->show_dump_window($self->{ELEMENTS}, 'asciio elements') ;
}

#----------------------------------------------------------------------------------------------

sub test
{
my ($self) = @_ ;

#~ print Data::TreeDumper::DumpTree $self, 'asciio', MAX_DEPTH => 2 ;

$self->test_diff() ;
}

