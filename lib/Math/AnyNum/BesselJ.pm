use 5.014;
use warnings;

our ($ROUND);

Class::Multimethods::multimethod __BesselJ__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $n) = @_;

    $n = Math::GMPz::Rmpz_get_d($n);

    # Limit goes to zero when n goes to +/-Infinity
    if (($n < Math::AnyNum::LONG_MIN or $n > Math::AnyNum::ULONG_MAX)
        and Math::MPFR::Rmpfr_number_p($x)) {
        Math::MPFR::Rmpfr_set_ui($x, 0, $ROUND);
        return $x;
    }

    if ($n == 0) {
        Math::MPFR::Rmpfr_j0($x, $x, $ROUND);
    }
    elsif ($n == 1) {
        Math::MPFR::Rmpfr_j1($x, $x, $ROUND);
    }
    else {
        Math::MPFR::Rmpfr_jn($x, $n, $x, $ROUND);
    }

    $x;
};

Class::Multimethods::multimethod __BesselJ__ => qw(Math::MPFR $) => sub {
    my ($x, $n) = @_;

    if ($n == 0) {
        Math::MPFR::Rmpfr_j0($x, $x, $ROUND);
    }
    elsif ($n == 1) {
        Math::MPFR::Rmpfr_j1($x, $x, $ROUND);
    }
    else {
        Math::MPFR::Rmpfr_jn($x, $n, $x, $ROUND);
    }

    $x;
};

1;
