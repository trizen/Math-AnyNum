#!/usr/bin/perl

use lib qw(../lib);
use Math::AnyNum qw(:overload tau fibonacci);

my $S = sqrt(5);
my $T = (1 + $S) / 2;
my $U = 2 / (1 + $S);

sub fib_cf {
    my ($n) = @_;
    (($T**$n - ($U**$n * cos(tau * $n))) / $S)->round(0);
}

for (my $i = 10 ; $i <= 100 ; $i += 10) {
    my $f = fib_cf($i);
    print "F($i) = $f\n";
    if ($f != fibonacci($i)) {
        warn "However, this is incorrect!";
    }
}
