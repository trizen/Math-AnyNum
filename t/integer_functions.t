#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 188;

use Math::AnyNum qw(:ntheory);

my $o = 'Math::AnyNum';

is(factorial(0), 1);
is(factorial(5), 120);

is(factorial($o->new(5)), 120);

is(binomial(42, 39),  11480);
is(binomial(-4, -42), 10660);
is(binomial(-4, 42),  14190);

is(binomial(42,          $o->new(39)), 11480);
is(binomial($o->new(42), 39),          11480);
is(binomial($o->new(42), $o->new(39)), 11480);

is(fibonacci(12), 144);
is(lucas(15),     1364);

is(fibonacci($o->new(12)), 144);
is(lucas($o->new(15)),     1364);

is(ipow(2,  10), 1024);
is(ipow(-2, 10), 1024);
is(ipow(-2, 11), -2048);
is(ipow(-2, -1), 0);
is(ipow(-2, -2), 0);
is(ipow(-1, -1), -1);
is(ipow(-1, 0),  1);

is(ipow(2,   10.5), 1024);
is(ipow(2.5, 10.5), 1024);
is(ipow(2.5, 10),   1024);

is(ipow(2,          $o->new(10)), 1024);
is(ipow($o->new(2), 10),          1024);
is(ipow($o->new(2), $o->new(10)), 1024);

is(ipow(2,            $o->new(10.5)), 1024);
is(ipow($o->new(2.5), 10.5),          1024);
is(ipow($o->new(2),   10.5),          1024);
is(ipow($o->new(2.5), $o->new(10)),   1024);
is(ipow($o->new(2.5), 10),            1024);

is(lcm(13,          14),          182);
is(lcm(14,          $o->new(13)), 182);
is(lcm($o->new(14), 13),          182);

is(gcd(20,          12),          4);
is(gcd($o->new(20), 12),          4);
is(gcd(20,          $o->new(12)), 4);

is(bernfrac(-2),          'NaN');
is(bernfrac(-1),          'NaN');
is(bernfrac(0),           1);
is(bernfrac(1),           '1/2');
is(bernfrac(30),          '8615841276005/14322');
is(bernfrac($o->new(30)), '8615841276005/14322');
is(bernfrac(52),          '-801165718135489957347924991853/1590');
is(bernfrac(54),          '29149963634884862421418123812691/798');
is(bernfrac($o->new(54)), '29149963634884862421418123812691/798');

is(harmfrac(-2),          'NaN');
is(harmfrac(-1),          'NaN');
is(harmfrac(0),           '0');
is(harmfrac(1),           '1');
is(harmfrac(10),          '7381/2520');
is(harmfrac($o->new(10)), '7381/2520');

is(valuation(14,           0),          0);
is(valuation(64,           2),          6);
is(valuation($o->new(128), 2),          7);
is(valuation(128,          $o->new(2)), 7);
is(valuation($o->new(128), $o->new(2)), 7);

is(remdiv(64 * 3 * 3,   3),          64);
is(remdiv(12,           0),          12);
is(remdiv(37,           5),          37);
is(remdiv($o->new(576), 3),          64);
is(remdiv(576,          $o->new(3)), 64);
is(remdiv($o->new(576), $o->new(3)), 64);
is(remdiv(1,            1),          1);
is(remdiv(0,            0),          0);

is(iadd(3,          4),           7);
is(iadd(-3,         -4),          -7);
is(iadd($o->new(3), 4),           7);
is(iadd($o->new(3), -4),          -1);
is(iadd($o->new(3), $o->new(-4)), -1);
is(iadd(3,          $o->new(-4)), -1);

is(isub(13,           3),           10);
is(isub(13,           -3),          16);
is(isub($o->new(13),  -3),          16);
is(isub(-13,          -3),          -10);
is(isub(-13,          $o->new(-3)), -10);
is(isub($o->new(-13), $o->new(-3)), -10);

is(imul(13,          2),           26);
is(imul(13,          -2),          -26);
is(imul(-13,         -2),          26);
is(imul($o->new(13), 2),           26);
is(imul($o->new(13), -2),          -26);
is(imul($o->new(13), $o->new(-2)), -26);
is(imul(13,          $o->new(-2)), -26);

is(idiv(1234,           10),           123);
is(idiv(1234,           -10),          -123);
is(idiv(-1234,          10),           -123);
is(idiv($o->new(1234),  -10),          -123);
is(idiv($o->new(-1234), 10),           -123);
is(idiv($o->new(-1234), $o->new(10)),  -123);
is(idiv(1234,           $o->new(-10)), -123);

is(imod(1234,           10),           4);
is(imod(1234,           -10),          -6);
is(imod(-1234,          -10),          -4);
is(imod($o->new(1234),  -10),          -6);
is(imod($o->new(-1234), -10),          -4);
is(imod($o->new(-1234), $o->new(-10)), -4);
is(imod($o->new(1234),  10),           4);

is(iroot(1234,           10),         2);
is(iroot(12345,          9),          2);
is(iroot(12345,          $o->new(9)), 2);
is(iroot($o->new(12345), 9),          2);
is(iroot($o->new(12345), $o->new(9)), 2);
is(iroot(-1,             2),          'NaN');
is(iroot(-2,             2),          'NaN');
is(iroot(1,              1),          1);
is(iroot(1,              2),          1);
is(iroot(-1,             1),          -1);
is(iroot(-2,             1),          -2);

is(isqrt(100),               10);
is(isqrt(987654),            993);
is(isqrt($o->new('987654')), 993);
is(isqrt(-1),                'NaN');
is(isqrt(-2),                'NaN');
is(isqrt(0),                 0);

is(icbrt(125),   5);
is(icbrt(1234),  10);
is(icbrt(-1234), -10);
is(icbrt(1),     1);
is(icbrt(0),     0);
is(icbrt(-1),    -1);

is(ilog(1234),   7);
is(ilog(123456), 11);
is(ilog(10000,          $o->new(10)), 4);
is(ilog(10000,          10),          4);
is(ilog($o->new(10000), 10),          4);
is(ilog($o->new('123456')), 11);
is(ilog(-1),                'NaN');

is(ilog2(64),             6);
is(ilog10(1000),          3);
is(ilog2($o->new(12345)), 13);
is(ilog10($o->new(999)),  2);
is(ilog2(-1),             'NaN');
is(ilog10(-1),            'NaN');

is(join(' ', isqrtrem(1234)), '35 9');
is(join(' ', isqrtrem(100)),  '10 0');
is(join(' ', irootrem(1234,     2)), '35 9');
is(join(' ', irootrem(1234,     5)), '4 210');
is(join(' ', irootrem(1234,     1)), '1234 0');
is(join(' ', irootrem('279841', 4)), '23 0');

is(powmod(123,          456,          19),          11);
is(powmod($o->new(123), 456,          19),          11);
is(powmod($o->new(123), $o->new(456), 19),          11);
is(powmod($o->new(123), $o->new(456), $o->new(19)), 11);
is(powmod(123,          $o->new(456), $o->new(19)), 11);
is(powmod(123,          $o->new(456), 19),          11);
is(powmod(123,          456,          $o->new(19)), 11);

is(powmod(123, -1, 17), 13);
is(powmod(123, -2, 17), 16);
is(powmod(123, -3, 17), 4);
is(powmod(123, -1, 15), 'NaN');
is(powmod(123, -2, 15), 'NaN');
is(powmod(123, -3, 15), 'NaN');

is(invmod(123,          17),          13);
is(invmod(123,          15),          'NaN');
is(invmod($o->new(123), 17),          13);
is(invmod($o->new(123), $o->new(17)), 13);
is(invmod(123,          $o->new(17)), 13);
is(invmod($o->new(123), 15),          'NaN');
is(invmod($o->new(123), $o->new(15)), 'NaN');

ok(is_power('279841'), '23^4');
ok(is_power(100, 2),  '10^2');
ok(is_power(125, 3),  '5^3');
ok(is_power(1,   13), '1^x');
ok(is_power(-1,  3),  '(-1)^odd');
ok(!is_power(-1,   2), '(-1)^even');
ok(!is_power(-123, 5), '-123');
ok(!is_power(0,    0), '0^0');
ok(is_power(0, 1), '0^1');
ok(is_power(0, 2), '0^2');
ok(is_power(0, 3), '0^3');
ok(is_power(1),   'is_power(1)');
ok(is_power(-1),  'is_power(-1)');
ok(!is_power(-2), 'is_power(-2)');
ok(is_power(0),   'is_power(0)');

ok(is_square(100), 'is_square(100)');
ok(!is_square(99), 'is_square(99)');
ok(!is_square(-1), 'is_square(-1)');
ok(is_square(1),   'is_square(-1)');
ok(is_square(0),   'is_square(0)');

ok(is_prime('165001'),          'is_prime');
ok(is_prime($o->new('165001')), 'is_prime');
ok(is_prime($o->new('165001'), 30), 'is_prime');
ok(!is_prime('113822804831'), '!is_prime');
ok(!is_prime('113822804831',          30),          '!is_prime');
ok(!is_prime($o->new('113822804831'), $o->new(30)), '!is_prime');

is(next_prime('165001'),          '165037');
is(next_prime($o->new('165001')), '165037');