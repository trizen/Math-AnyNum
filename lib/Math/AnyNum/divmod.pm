use 5.014;
use warnings;

sub __divmod__ {
    my ($x, $y) = @_;

    Math::GMPz::Rmpz_sgn($y)
        || return (&Math::AnyNum::_nan(), &Math::AnyNum::_nan());

    Math::GMPz::Rmpz_divmod($x, $y, $x, $y);
    ($x, $y);
}

1;
