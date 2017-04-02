use 5.014;
use warnings;

sub __gcd__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_gcd($x, $x, $y);
    $x;
}

1;
