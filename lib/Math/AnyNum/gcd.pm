use 5.014;
use warnings;

sub __gcd__ {
    my ($x, $y) = @_;

    ref($y)
      ? Math::GMPz::Rmpz_gcd($x, $x, $y)
      : Math::GMPz::Rmpz_gcd_ui($x, $x, $y);

    $x;
}

1;
