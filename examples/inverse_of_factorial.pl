#!/usr/bin/perl

# The inverse of n factorial, based on the inverse of Stirling's approximation.

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use ntheory qw(factorial);
use Math::AnyNum qw(:constant tau e);

use constant S => tau->copy->sqrt->log;
use constant T => tau->copy->root(-2 * e);

sub inv_fac_W {
    my ($n) = @_;
    my $L = log($n) - S;
    $L / ($L / e)->lambert_w - 1/2;
}

sub inv_fac_lgrt {
    my ($n) = @_;
    (T * $n**(1 / e))->lgrt * e - 1/2;
}

for my $z(1..100) {
    my $n = Math::AnyNum->new($z);

    my $f = Math::AnyNum::factorial($z);
    my $i = inv_fac_W($f);
    my $j = inv_fac_lgrt($f);

    printf("F(%2s!) =~ %s\n", $n, $i);

    if ($i->copy->round(-20) != $j->copy->round(-20)) {
        die "$i != $j";
    }

    if ($i->copy->round(0) != $n) {
        die "However that is incorrect! (expected: $n -- got ", $i->copy->round(0), ")";
    }
}
