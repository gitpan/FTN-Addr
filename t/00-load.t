#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'FTN::Addr' );
}

diag( "Testing FTN::Addr $FTN::Addr::VERSION, Perl $], $^X" );
