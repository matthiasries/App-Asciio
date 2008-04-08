
package App::Asciio ;

$|++ ;

use strict;
use warnings;

#------------------------------------------------------------------------------------------------------

sub get_key_modifiers
{
my ($event) = @_ ;

my $key_modifiers = $event->state() ;

my $modifiers = $key_modifiers =~ /control-mask/ ? 'C' :0 ;
$modifiers .= $key_modifiers =~ /mod1-mask/ ? 'A' :0 ;
$modifiers .= $key_modifiers =~ /shift-mask/ ? 'S' :0 ;

return($modifiers) ;
}

#------------------------------------------------------------------------------------------------------

my Readonly $SHORTCUTS = 0 ;
my Readonly $CODE = 1 ;
my Readonly $ARGUMENTS = 2 ;
my Readonly $CONTEXT_MENUE_SUB = 3 ;
my Readonly $CONTEXT_MENUE_ARGUMENTS = 4 ;
my Readonly $NAME= 5 ;

sub run_actions
{
my ($self, @actions) = @_ ;

for my $action (@actions)
	{
	my @arguments ;
	
	if('ARRAY' eq ref $action)
		{
		($action, @arguments) = @{ $action } ;
		}
		
	my ($modifiers, $action_key) = $action =~ /(...)-(.*)/ ;
	
	if(exists $self->{CURRENT_ACTIONS}{$action})
		{
		if('HASH' eq ref $self->{CURRENT_ACTIONS}{$action})
			{
			my $action_group_name = 
				$self->{CURRENT_ACTIONS}{$action}{GROUP_NAME}  || 'unnamed action group' ;
			
			print "using action handlers group '$action_group_name'\n" ;
			
			$self->{CURRENT_ACTIONS} = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			print "Handling input '$modifiers + $action_key' with action '$self->{CURRENT_ACTIONS}{$action}[$NAME]'.\n" ;
			
			if(defined $self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS])
				{
				$self->{CURRENT_ACTIONS}{$action}[$CODE]->
						(
						$self,
						$self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS],
						@arguments
						) ;
				}
			else
				{
				$self->{CURRENT_ACTIONS}{$action}[$CODE]->($self, @arguments) ;
				}
			}
		}
	else
		{
		print "no handler for input '$modifiers + $action_key'.\n" ;
		$self->{CURRENT_ACTIONS} = $self->{ACTIONS} ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub run_actions_by_name
{
my ($self, @actions) = @_ ;

my $current_actions_by_name = $self->{ACTIONS_BY_NAME} ;

for my $action (@actions)
	{
	my @arguments ;
	
	if('ARRAY' eq ref $action)
		{
		($action, @arguments) = @{ $action } ;
		}
		
	if(exists $current_actions_by_name->{$action})
		{
		if('HASH' eq ref $self->{CURRENT_ACTIONS}{$action})
			{
			print "using action handlers group '$action'\n" ;
			$current_actions_by_name = $self->{CURRENT_ACTIONS}{$action} ;
			}
		else
			{
			print "running action '$action'.\n" ;
			
			if(defined $current_actions_by_name->{$action}[$ARGUMENTS])
				{
				$current_actions_by_name->{$action}[$CODE]->
						(
						$self,
						$self->{CURRENT_ACTIONS}{$action}[$ARGUMENTS],
						@arguments
						) ;
				}
			else
				{
				$current_actions_by_name->{$action}[$CODE]->($self, @arguments) ;
				}
			}
		}
	else
		{
		print "no handler for '$action'.\n" ;
		last ;
		}
	}
}

#------------------------------------------------------------------------------------------------------

sub exists_action
{
my ($self, $action) = @_ ;

return exists $self->{CURRENT_ACTIONS}{$action} ;
}

#------------------------------------------------------------------------------------------------------

1 ;
