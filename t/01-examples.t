#perl -T

use Test::More tests => 19;

BEGIN {
	use_ok( 'FTN::Addr' );
}

my $a = FTN::Addr -> new('1:23/45');
ok(defined $a, 'first created');

my $b = FTN::Addr -> new('1:23/45@fidonet');
ok(defined $b, 'second created');

ok($a eq $b, "Hey! They are the same!");

ok($a != $b, 'but objects are different');

$b -> set_domain('othernet');

ok($a ne $b, 'different domains...');

ok(defined $b -> new('44.22', $a), 'with second arg');

is($a -> f4, "1:23/45.0", 'f4');

is($a -> s4, "1:23/45", 's4');

is($a -> f5, '1:23/45.0@fidonet', 'f5');

is($a -> s5, '1:23/45@fidonet', 's5');




my $t = FTN::Addr -> new('1:23/45');
ok(defined $t, 't');

$t -> new('1:22/33.44@fidonet') or die 'something wrong!';
ok(defined $t, 't with second');

my $an = FTN::Addr -> new('99', $t); # address in $an is 1:22/99.0@fidonet
ok(defined $an, 'an');

is($an -> fqfa, 'fidonet#1:22/99.0', 'fqfa');

is($an -> bs, 'fidonet.1.22.99.0', 'brake style');




my $first = FTN::Addr -> new('1:23/45.66@fidonet');

my $second = FTN::Addr -> new('1:23/45.66@FidoNet');

ok(FTN::Addr -> equal($first, $second), 'FTN::Addr -> equal()');

ok($first eq $second, 'eq');

ok($first != $second, '==');
