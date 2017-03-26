#!/usr/bin/perl

# Approximate nth-roots using Newton's method.

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:constant);

sub nth_root {
    my ($n, $x) = @_;

    $n->float;
    $x->float;

    my $eps = 10**-($Math::AnyNum::PREC / 4);

    my $m = $n;
    my $r = 0;

    while (abs($m - $r) > $eps) {
        $r = $m;
        $m = ((($n - 1) * ($r) + $x / ($r**($n - 1))) / ($n));
    }

    $r;
}

say nth_root(2,  2);
say nth_root(3,  125);
say nth_root(7,  42**7);
say nth_root(42, 987**42);
