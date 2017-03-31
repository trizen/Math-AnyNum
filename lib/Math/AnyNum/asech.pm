use 5.014;
use warnings;

our ($ROUND, $PREC);

# asech(x) = acosh(1/x)
Class::Multimethods::multimethod __asech__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Return a complex number for x < 0 or x > 1
    if (   Math::MPFR::Rmpfr_cmp_ui($x, 1) > 0
        or Math::MPFR::Rmpfr_cmp_ui($x, 0) < 0) {
        (@_) = _mpfr2mpc($x);
        goto &__asech__;
    }

    Math::MPFR::Rmpfr_ui_div($x, 1, $x, $ROUND);
    Math::MPFR::Rmpfr_acosh($x, $x, $ROUND);
    $x;
};

# asech(x) = acosh(1/x)
Class::Multimethods::multimethod __asech__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    Math::MPC::Rmpc_acosh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __asech__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__asech__;
};

Class::Multimethods::multimethod __asech__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__asech__;
};

1;
