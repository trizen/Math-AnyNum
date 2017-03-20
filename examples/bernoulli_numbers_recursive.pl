#!/usr/bin/perl

# Recursive computation of Bernoulli numbers.
# https://en.wikipedia.org/wiki/Bernoulli_number#Recursive_definition

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Memoize qw(memoize);
#use ntheory qw(binomial);
#use Math::BigNum qw(binomial);
use Math::AnyNum qw(:constant);

memoize('bernoulli');

sub bernoulli {
    my ($n) = @_;

    return 0.5 if $n == "1";
    return 0.0 if $n %  "2";
    return 1.0 if $n == "0";

    my $bern = 0.5 - 1/($n+1);
    for (my $k = "2" ; $k < $n ; $k += "2") {
        $bern -= bernoulli($k) * Math::AnyNum::binomial($n, $k) / ($n - $k + 1);
    }
    $bern;
}

foreach my $i (0 .. 100) {
    printf "B%-3d = %s\n", "2"*$i, bernoulli("2"*$i);
}
