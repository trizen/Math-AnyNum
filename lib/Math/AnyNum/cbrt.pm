use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __cbrt__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Complex for x < 0
    if (Math::MPFR::Rmpfr_sgn($x) < 0) {
        (@_) = _mpfr2mpc($_[0]);
        goto &__cbrt__;
    }

    Math::MPFR::Rmpfr_cbrt($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __cbrt__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    state $three_inv = do {
        my $r = Math::MPC::Rmpc_init2_nobless($PREC);
        Math::MPC::Rmpc_set_ui($r, 3, $ROUND);
        Math::MPC::Rmpc_ui_div($r, 1, $r, $ROUND);
        $r;
    };
    Math::MPC::Rmpc_pow($x, $x, $three_inv, $ROUND);
    $x;
};

1;
