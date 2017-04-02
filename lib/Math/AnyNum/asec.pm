use 5.014;
use warnings;

our ($ROUND);

# asec(x) = acos(1/x)
Class::Multimethods::multimethod __asec__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Return a complex number for x > -1 and x < 1
    if (    Math::MPFR::Rmpfr_cmp_ui($x, 1) < 0
        and Math::MPFR::Rmpfr_cmp_si($x, -1) > 0) {
        (@_) = _mpfr2mpc($x);
        goto &__asec__;
    }

    Math::MPFR::Rmpfr_ui_div($x, 1, $x, $ROUND);
    Math::MPFR::Rmpfr_acos($x, $x, $ROUND);
    $x;
};

# asec(x) = acos(1/x)
Class::Multimethods::multimethod __asec__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    Math::MPC::Rmpc_acos($x, $x, $ROUND);
    $x;
};

1;
