#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 84;

use Math::AnyNum;

{
    is(Math::AnyNum->new_c(1.234567,  7.65432)->round(-3), '1.235+7.654i');
    is(Math::AnyNum->new_c(-1.234567, 0.00001)->round(-3), '-1.235');
}

{
    use Math::AnyNum qw(:constant);

    #[+0.5,      0,         0],
    #[-0.5,      0,         0],
    #[3.045,     3.04,      -2],
    #[-2.5,      -2,        0],
    #[+2.5,      2,         0],

    my @tests = (
                 [+1.6,      +2,        0],
                 [+1.5,      +2,        0],
                 [+1.4,      +1,        0],
                 [+0.6,      +1,        0],
                 [+0.4,      0,         0],
                 [-0.4,      0,         0],
                 [-0.6,      -1,        0],
                 [-1.4,      -1,        0],
                 [-1.5,      -2,        0],
                 [-1.6,      -2,        0],
                 [3.016,     3.02,      -2],
                 [3.013,     3.01,      -2],
                 [3.015,     3.02,      -2],
                 [3.04501,   3.05,      -2],
                 [3.03701,   3.04,      -2],
                 [-1234.555, -1000,     3],
                 [-1234.555, -1200,     2],
                 [-1234.555, -1230,     1],
                 [-1234.555, -1235,     0],
                 [-1234.555, -1234.6,   -1],
                 [-1234.555, -1234.56,  -2],
                 [-1234.555, -1234.555, -3],
                 [-2.7,      -3,        0],
                 [-2.3,      -2,        0],
                 [-2.0,      -2,        0],
                 [-1.7,      -2,        0],
                 [-1.5,      -2,        0],
                 [-1.3,      -1,        0],
                 [-1.0,      -1,        0],
                 [-0.7,      -1,        0],
                 [-0.3,      0,         0],
                 [+0.0,      0,         0],
                 [+0.3,      0,         0],
                 [+0.7,      1,         0],
                 [+1.0,      1,         0],
                 [+1.3,      1,         0],
                 [+1.5,      2,         0],
                 [+1.7,      2,         0],
                 [+2.0,      2,         0],
                 [+2.3,      2,         0],
                 [+2.7,      3,         0],
                );

    foreach my $group (@tests) {
        my ($orig, $expected, $places) = @{$group};
        my $rounded = $orig->copy->round($places);
        is("$rounded", "$expected", "($orig, $expected, $places)");
        ok($rounded == $expected);
    }
}
