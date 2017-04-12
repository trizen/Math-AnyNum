use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __inv__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_ui_div($x, 1, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __inv__ => qw(Math::GMPq) => sub {
    my ($x) = @_;

    # Check for division by zero
    if (!Math::GMPq::Rmpq_sgn($x)) {
        (@_) = _mpq2mpfr($x);
        goto &__inv__;
    }

    Math::GMPq::Rmpq_inv($x, $x);
    $x;
};

Class::Multimethods::multimethod __inv__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpq($_[0]);
    goto &__inv__;
};

Class::Multimethods::multimethod __inv__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

1;
