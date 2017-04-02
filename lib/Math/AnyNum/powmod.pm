use 5.014;
use warnings;

sub __powmod__ {    # takes three Math::GMPz objects
    my ($x, $y, $z) = @_;

    Math::GMPz::Rmpz_sgn($z) || return;

    if (Math::GMPz::Rmpz_sgn($y) < 0) {
        Math::GMPz::Rmpz_gcd($x, $x, $z);
        Math::GMPz::Rmpz_cmp_ui($x, 1) == 0 or return;
    }

    Math::GMPz::Rmpz_powm($x, $x, $y, $z);
    $x;
}

1;
