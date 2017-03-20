#!/usr/bin/perl

#
## http://rosettacode.org/wiki/Arithmetic-geometric_mean/Calculate_Pi#Perl
#

use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(:constant);

my $digits = shift || 100;    # Get number of digits from command line
print agm_pi($digits), "\n";

sub agm_pi {
    my $digits = shift;

    my $acc = $digits + 8;
    local $Math::AnyNum::PREC = 4 * $digits;

    my $HALF = Math::AnyNum->new("0.5");
    my ($an, $bn, $tn, $pn) = (1, $HALF->copy->sqrt, $HALF->copy->mul($HALF), 1);
    while ($pn < $acc) {
        my $prev_an = $an->copy;
        $an->add($bn)->bmul($HALF);
        $bn->mul($prev_an)->sqrt;
        $prev_an->sub($an);
        $tn->sub($pn * $prev_an * $prev_an);
        $pn->add($pn);
    }
    $an->add($bn);
    $an->mul($an)->div(4 * $tn);
    return $an;
    #return $an->as_float($digits);
}
