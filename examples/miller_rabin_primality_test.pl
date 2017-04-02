#!/usr/bin/perl

#
## https://rosettacode.org/wiki/Miller%E2%80%93Rabin_primality_test#Perl
#

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(irand);

sub is_prime {
    my ($n, $k) = @_;

    return 1 if $n == 2;
    return 0 if $n < 2 or $n % 2 == 0;

    my $d = Math::AnyNum->new($n - 1);
    my $s = 0;

    while (!($d & 1)) {
        $d >>= 1;
        ++$s;
    }

    #my $s = $d->valuation(2);
    #$d >>= $s;

    # ==OR==
    #$d->remove(2);

  LOOP: for (1 .. $k) {
        my $a = 2 + irand($n - 2);

        my $x = $a->powmod($d, $n);
        next if $x == 1 or $x == $n - 1;

        for (1 .. $s - 1) {
            $x = ($x * $x) % $n;
            return 0  if $x == 1;
            next LOOP if $x == $n - 1;
        }
        return 0;
    }
    return 1;
}

say join ", ", grep { is_prime($_, 10) } (1 .. 1000);
