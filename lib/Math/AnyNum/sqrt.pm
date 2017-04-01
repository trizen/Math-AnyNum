use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __sqrt__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Complex for x < 0
    if (Math::MPFR::Rmpfr_sgn($x) < 0) {
        (@_) = _mpfr2mpc($_[0]);
        goto &__sqrt__;
    }

    Math::MPFR::Rmpfr_sqrt($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sqrt__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sqrt($x, $x, $ROUND);
    $x;
};

1;
