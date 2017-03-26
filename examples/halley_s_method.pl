#!/usr/bin/perl

# Approximate nth-roots using Newton's method.

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:constant);

sub derivatives {
    my ($x, $m, $k) = @_;
    my $fx   = $x**$m - $k;
    my $dfx  = ($m * $x**($m - 1));
    my $ddfx = (($m - 1) * $m) * $x**($m - 2);
    ($fx, $dfx, $ddfx);
}

sub halleys_method {
    my ($x0, $m0, $k0) = @_;

    my $x = $x0;
    my $m = $m0->copy->float;
    my $k = $k0->copy->float;

    my @fx  = derivatives($x, $m, $k);
    my $eps = 10**-($Math::AnyNum::PREC / 4);
    my $r   = $fx[0] / ($fx[1] - ($fx[0] * $fx[2]) / (2 * $fx[1]));

    while (abs($fx[0]) > $eps) {
        $r = ($fx[0] / ($fx[1] - (($fx[0] * $fx[2]) / (2 * $fx[1]))));
        $x -= $r;
        @fx = derivatives($x, $m, $k);
    }

    return $x;
}

# Real roots
say halleys_method(1, 2,  2);
say halleys_method(1, 3,  125);
say halleys_method(1, 7,  42**7);
say halleys_method(1, 42, 987**42);

# Complex roots
say halleys_method(sqrt(-1), 2,  -1);
say halleys_method(sqrt(-1), 2,  -2);
say halleys_method(sqrt(-1), -3, -4);
