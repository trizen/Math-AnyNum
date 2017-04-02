use 5.014;
use warnings;

sub __lcm__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_lcm($x, $x, $y);
    $x;
}

1;
