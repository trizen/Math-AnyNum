#!/usr/bin/perl

#
## Some simple approximations to the prime counting function.
#

use 5.010;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:overload);

foreach my $n (1 .. 10) {
    my $x = 10**$n;

    my $f1 = $x->sqr->idiv(($x + 1)->lngamma);
    my $f2 = int $x->Li;

    say "PI($x) =~ ", $f1, ' =~ ', $f2;
}
