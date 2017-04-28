use 5.014;
use warnings;

sub __lcm__ {
    my ($x, $y) = @_;

    ref($y)
      ? Math::GMPz::Rmpz_lcm($x, $x, $y)
      : Math::GMPz::Rmpz_lcm_ui($x, $x, $y);

    $x;
}

1;
