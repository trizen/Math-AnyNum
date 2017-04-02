use 5.014;
use warnings;

our ($ROUND);

Class::Multimethods::multimethod __BesselY__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $n) = @_;

    $n = Math::GMPz::Rmpz_get_d($n);

    if (   $n < Math::AnyNum::LONG_MIN
        or $n > Math::AnyNum::ULONG_MAX) {
        if (Math::MPFR::Rmpfr_sgn($x) < 0
            or !Math::MPFR::Rmpfr_number_p($x)) {
            Math::MPFR::Rmpfr_set_nan($x);
            return $x;
        }

        if ($n < 0) {
            Math::MPFR::Rmpfr_set_inf($x, 1);
        }
        else {
            Math::MPFR::Rmpfr_set_inf($x, -1);
        }

        return $x;
    }

    if ($n == 0) {
        Math::MPFR::Rmpfr_y0($x, $x, $ROUND);
    }
    elsif ($n == 1) {
        Math::MPFR::Rmpfr_y1($x, $x, $ROUND);
    }
    else {
        Math::MPFR::Rmpfr_yn($x, $n, $x, $ROUND);
    }

    $x;
};

Class::Multimethods::multimethod __BesselY__ => qw(Math::MPFR $) => sub {
    my ($x, $n) = @_;

    if ($n == 0) {
        Math::MPFR::Rmpfr_y0($x, $x, $ROUND);
    }
    elsif ($n == 1) {
        Math::MPFR::Rmpfr_y1($x, $x, $ROUND);
    }
    else {
        Math::MPFR::Rmpfr_yn($x, $n, $x, $ROUND);
    }

    $x;
};

1;
