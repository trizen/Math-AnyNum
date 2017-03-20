#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 100;

{
    use Math::AnyNum qw(:constant);

    is(ref(42), 'Math::AnyNum');
    like(sqrt(42), qr/^6\.480740698407860230965967436087996\d*\z/);
    like(sqrt(-1), qr/^i\z/);
    like(sqrt(-3.5), qr/^1\.87082869338697069279187436\d*i\z/);

    my $x = -2;
    like($x->copy->sqrt, qr/^1\.4142135623730950488016\d*i\z/);
    ok($x == -2);

    $x->sqrt;
    ok($x != -2);

    my $z = 42;
    is(-$z, "-42");
    like(-sqrt(sqrt($z)), qr/^-2\.5457298950218305182697889605762886\d*\z/);

    is(-(3+4*sqrt(-1)), -3 - 4*sqrt(-1));

    is(3.0000, 3);
    is(1e3, 1000);

    # Addition
    is(5+18, 23);
    like(sqrt(2) + sqrt(3), qr/^3\.1462643699419723423291350657155704455\d*\z/);
    like(sqrt(-5) + sqrt(-2), qr/^3\.65028153987288474521086239294097431\d*i\z/);

    like(3 + sqrt(2), qr/^4\.414213562373095048801\d*\z/);
    like(sqrt(2) + 3, qr/^4\.414213562373095048801\d*\z/);

    is(2.5, 5/2);
}
