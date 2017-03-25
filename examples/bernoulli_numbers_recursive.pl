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

sub binomial {
    Math::AnyNum->new($_[0])->binomial($_[1]);
}

sub bernoulli {
    my ($n) = @_;

    return 1 / 2 if $n == 1;
    return 0     if $n % 2;
    return 1     if $n == 0;

    my $bern = 1 / 2 - 1 / ($n + 1);
    for (my $k = "2" ; $k < $n ; $k += "2") {
        $bern -= bernoulli($k) * binomial($n, $k) / ($n - $k + 1);
    }
    $bern;
}

foreach my $i (0 .. 100) {
    printf "B%-3d = %s\n", "2" * $i, bernoulli("2" * $i);
}
