use 5.014;
use warnings;

our ($ROUND, $PREC);

# Implemented as:
#    eta(1) = ln(2)
#    eta(x) = (1 - 2**(1-x)) * zeta(x)

sub __eta__ {
    my ($x) = @_;      # $n is always a Math::MPFR object

    # Special case for eta(1) = log(2)
    if (!Math::MPFR::Rmpfr_cmp_ui($x, 1)) {
        Math::MPFR::Rmpfr_add_ui($x, $x, 1, $ROUND);
        Math::MPFR::Rmpfr_log($x, $x, $ROUND);
        return $x;
    }

    my $p = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set($p, $x, $ROUND);
    Math::MPFR::Rmpfr_ui_sub($p, 1, $p, $ROUND);
    Math::MPFR::Rmpfr_ui_pow($p, 2, $p, $ROUND);
    Math::MPFR::Rmpfr_ui_sub($p, 1, $p, $ROUND);

    Math::MPFR::Rmpfr_zeta($x, $x, $ROUND);
    Math::MPFR::Rmpfr_mul($x, $x, $p, $ROUND);

    $x;
}

1;
