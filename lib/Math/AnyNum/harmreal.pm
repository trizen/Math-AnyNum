use 5.014;
use warnings;

our ($ROUND, $PREC);

sub __harmreal__ {
    my ($x) = @_;    # $x is a Math::MPFR object

    Math::MPFR::Rmpfr_add_ui($x, $x, 1, $ROUND);
    Math::MPFR::Rmpfr_digamma($x, $x, $ROUND);

    my $y = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_euler($y, $ROUND);
    Math::MPFR::Rmpfr_add($x, $x, $y, $ROUND);

    $x;
}

1;
