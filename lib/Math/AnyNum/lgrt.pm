use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __lgrt__ => qw(Math::MPFR) => sub {
    my ($d) = @_;

    # Return a complex number for x < e^(-1/e)
    if (Math::MPFR::Rmpfr_cmp_d($d, CORE::exp(-1 / CORE::exp(1))) < 0) {
        (@_) = _mpfr2mpc($d);
        goto &__lgrt__;
    }

    Math::MPFR::Rmpfr_log($d, $d, $ROUND);

    my $p = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_ui_pow_ui($p, 10, CORE::int($PREC >> 2), $ROUND);
    Math::MPFR::Rmpfr_ui_div($p, 1, $p, $ROUND);

    my $x = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_ui($x, 1, $ROUND);

    my $y = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_ui($y, 0, $ROUND);

    my $count = 0;
    my $tmp   = Math::MPFR::Rmpfr_init2($PREC);

    while (1) {
        Math::MPFR::Rmpfr_sub($tmp, $x, $y, $ROUND);
        Math::MPFR::Rmpfr_cmpabs($tmp, $p) <= 0 and last;

        Math::MPFR::Rmpfr_set($y, $x, $ROUND);

        Math::MPFR::Rmpfr_log($tmp, $x, $ROUND);
        Math::MPFR::Rmpfr_add_ui($tmp, $tmp, 1, $ROUND);

        Math::MPFR::Rmpfr_add($x, $x, $d, $ROUND);
        Math::MPFR::Rmpfr_div($x, $x, $tmp, $ROUND);
        last if ++$count > $PREC;
    }

    Math::MPFR::Rmpfr_set($d, $x, $ROUND);
    $d;
};

Class::Multimethods::multimethod __lgrt__ => qw(Math::MPC) => sub {
    my ($c) = @_;

    my $p = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_ui_pow_ui($p, 10, CORE::int($PREC >> 2), $ROUND);
    Math::MPFR::Rmpfr_ui_div($p, 1, $p, $ROUND);

    my $d = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_log($d, $c, $ROUND);

    my $x = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set($x, $c, $ROUND);
    Math::MPC::Rmpc_sqr($x, $x, $ROUND);
    Math::MPC::Rmpc_add_ui($x, $x, 1, $ROUND);
    Math::MPC::Rmpc_log($x, $x, $ROUND);

    my $y = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_ui($y, 0, $ROUND);

    my $tmp = Math::MPC::Rmpc_init2($PREC);
    my $abs = Math::MPFR::Rmpfr_init2($PREC);

    my $count = 0;
    while (1) {
        Math::MPC::Rmpc_sub($tmp, $x, $y, $ROUND);

        Math::MPC::Rmpc_abs($abs, $tmp, $ROUND);
        Math::MPFR::Rmpfr_cmp($abs, $p) <= 0 and last;

        Math::MPC::Rmpc_set($y, $x, $ROUND);

        Math::MPC::Rmpc_log($tmp, $x, $ROUND);
        Math::MPC::Rmpc_add_ui($tmp, $tmp, 1, $ROUND);

        Math::MPC::Rmpc_add($x, $x, $d, $ROUND);
        Math::MPC::Rmpc_div($x, $x, $tmp, $ROUND);
        last if ++$count > $PREC;
    }

    $x;
};

1;
