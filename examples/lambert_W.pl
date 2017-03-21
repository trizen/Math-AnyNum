#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 27 December 2016
# https://github.com/trizen

# A simple implementation of Lambert's W function in real numbers.

# Example: x^x = 100
#            x = exp(lambert_w(log(100)))
#            x =~ 3.59728502354042

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:constant);

sub lambert_w {
    my ($c) = @_;

    my $p = 1 / 10**($Math::AnyNum::PREC / log(10) * log(2));

    my $x = sqrt($c) + 1;
    my $y = 0;

    while (abs($x - $y) > $p) {
        $y = $x;
        $x = ($x + $c)/(1 + log($x));
    }

    log($x);
}

say exp(lambert_w(log(+100)));    # 3.59728502354041750549765225178228606913554305488657678372
say exp(lambert_w(log(-100)));    # 3.702029366602145942901939629527371028027770105829025506563+1.348231284711519013278314649698724804162921476143104754496i
