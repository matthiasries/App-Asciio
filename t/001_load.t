
# test module loading

use strict ;
use warnings ;

use Test::NoWarnings ;
use Test::Warn ;

use Test::More qw(no_plan);

use Test::Exception ;

warning_like
	{
	use_ok( 'App::Asciio' ) or BAIL_OUT("Can't load module"); 
	} qr//, 'warning from GTK' ;
