use 5.014;
use warnings;

our ($PREC, $ROUND);

Class::Multimethods::multimethod __agm__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;

    if (   Math::MPFR::Rmpfr_sgn($x) < 0
        or Math::MPFR::Rmpfr_sgn($y) < 0) {
        (@_) = (_mpfr2mpc($x), _mpfr2mpc($y));
        goto &__agm__;
    }

    Math::MPFR::Rmpfr_agm($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __agm__ => qw(Math::MPC Math::MPC) => sub {    # both arguments are modified
    my ($a0, $g0) = @_;

    # agm(0,  x) = 0
    if (!Math::MPC::Rmpc_cmp_si_si($a0, 0, 0)) {
        return $a0;
    }

    # agm(x, 0) = 0
    if (!Math::MPC::Rmpc_cmp_si_si($g0, 0, 0)) {
        return $g0;
    }

    my $a1 = Math::MPC::Rmpc_init2($PREC);
    my $g1 = Math::MPC::Rmpc_init2($PREC);
    my $t  = Math::MPC::Rmpc_init2($PREC);

    my $count = 0;
    {
        Math::MPC::Rmpc_add($a1, $a0, $g0, $ROUND);
        Math::MPC::Rmpc_div_2exp($a1, $a1, 1, $ROUND);

        Math::MPC::Rmpc_mul($g1, $a0, $g0, $ROUND);
        Math::MPC::Rmpc_add($t, $a0, $g0, $ROUND);
        Math::MPC::Rmpc_sqr($t, $t, $ROUND);
        Math::MPC::Rmpc_cmp_si_si($t, 0, 0) || return $t;
        Math::MPC::Rmpc_div($g1, $g1, $t, $ROUND);
        Math::MPC::Rmpc_sqrt($g1, $g1, $ROUND);
        Math::MPC::Rmpc_add($t, $a0, $g0, $ROUND);
        Math::MPC::Rmpc_mul($g1, $g1, $t, $ROUND);

        if (Math::MPC::Rmpc_cmp($a0, $a1) and ++$count < $PREC) {
            Math::MPC::Rmpc_set($a0, $a1, $ROUND);
            Math::MPC::Rmpc_set($g0, $g1, $ROUND);
            redo;
        }
    }

    $g0;
};

Class::Multimethods::multimethod __agm__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__agm__;
};

Class::Multimethods::multimethod __agm__ => qw(Math::MPC Math::MPFR) => sub {
    (@_) = ($_[0], _mpfr2mpc($_[1]));
    goto &__agm__;
};

1;
