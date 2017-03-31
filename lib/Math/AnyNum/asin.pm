use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __asin__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Return a complex number for x < -1 or x > 1
    if (   Math::MPFR::Rmpfr_cmp_ui($x, 1) > 0
        or Math::MPFR::Rmpfr_cmp_si($x, -1) < 0) {
        $x = _mpfr2mpc($x);
        Math::MPC::Rmpc_asin($x, $x, $ROUND);
        return $x;
    }

    Math::MPFR::Rmpfr_asin($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __asin__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_asin($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __asin__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__asin__;
};

Class::Multimethods::multimethod __asin__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__asin__;
};

1;
