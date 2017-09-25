#!/usr/bin/perl

# The formula for calculating the sum of consecutive
# numbers raised to a given power, such as:
#    1^p + 2^p + 3^p + ... + n^p
# where p is a positive integer.

# See also: https://en.wikipedia.org/wiki/Faulhaber%27s_formula

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:overload binomial);

# This function returns the nth Bernoulli number (Akiyama–Tanigawa algorithm)
# See: https://en.wikipedia.org/wiki/Bernoulli_number
sub bernoulli_number {
    my ($n) = @_;

    return 0 if $n > 1 && $n % 2;    # Bn = 0 for all odd n > 1

    my @A;
    for my $m (0 .. $n) {
        $A[$m] = 1 / ($m + 1);

        for (my $j = $m ; $j > 0 ; $j--) {
            $A[$j - 1] = $j * ($A[$j - 1] - $A[$j]);
        }
    }

    return $A[0];                    # which is Bn
}

# The Faulhaber's formula
# See: https://en.wikipedia.org/wiki/Faulhaber%27s_formula
sub faulhaber_s_formula {
    my ($p, $n) = @_;

    my $sum = 0;
    for my $j (0 .. $p) {
        if ($j % 2 == 0 or $j == 1) {
            $sum += binomial($p + 1, $j) * bernoulli_number($j) * $n**($p + 1 - $j);
        }
    }

    $sum / ($p + 1);
}

# Alternate expression using Bernoulli polynomials
# See: https://en.wikipedia.org/wiki/Faulhaber%27s_formula#Alternate_expressions
sub bernoulli_polynomials {
    my ($n, $x) = @_;

    my $sum = 0;
    for my $k (0 .. $n) {
        $sum += binomial($n, $k) * bernoulli_number($n - $k) * $x**$k;
    }

    $sum;
}

sub faulhaber_s_formula_2 {
    my ($p, $n) = @_;
    1 + (bernoulli_polynomials($p + 1, $n) - bernoulli_polynomials($p + 1, 1)) / ($p + 1);
}

# Test for 1^5 + 2^5 + 3^5 + ... + 10^5
foreach my $i (0 .. 10) {
    say "$i: ", faulhaber_s_formula(5, $i);
    say "$i: ", faulhaber_s_formula_2(5, $i);
}
