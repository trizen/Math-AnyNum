use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __acosh__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Return a complex number for x < 1
    if (Math::MPFR::Rmpfr_cmp_ui($x, 1) < 0) {
        $x = _mpfr2mpc($x);
        Math::MPC::Rmpc_acosh($x, $x, $ROUND);
        return $x;
    }

    Math::MPFR::Rmpfr_acosh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __acosh__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_acosh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __acosh__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__acosh__;
};

Class::Multimethods::multimethod __acosh__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__acosh__;
};

1;
