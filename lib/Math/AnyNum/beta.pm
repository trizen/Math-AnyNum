use 5.014;
use warnings;

our ($ROUND, $PREC);

# Implemented as:
#    beta(x,y) = gamma(x)*gamma(y) / gamma(x+y)

sub __beta__ {
    my ($x, $y) = @_;

    my $t = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_add($t, $x, $y, $ROUND);
    Math::MPFR::Rmpfr_gamma($t, $t, $ROUND);
    Math::MPFR::Rmpfr_gamma($x, $x, $ROUND);
    Math::MPFR::Rmpfr_gamma($y, $y, $ROUND);
    Math::MPFR::Rmpfr_mul($x, $x, $y, $ROUND);
    Math::MPFR::Rmpfr_div($x, $x, $t, $ROUND);

    $x;
}

1;
