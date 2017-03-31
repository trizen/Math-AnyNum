use 5.014;
use warnings;

our ($ROUND, $PREC);

# acot(x) = atan(1/x)
Class::Multimethods::multimethod __acot__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_ui_div($x, 1, $x, $ROUND);
    Math::MPFR::Rmpfr_atan($x, $x, $ROUND);
    $x;
};

# acot(x) = atan(1/x)
Class::Multimethods::multimethod __acot__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    Math::MPC::Rmpc_atan($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __acot__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__acot__;
};

Class::Multimethods::multimethod __acot__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__acot__;
};

1;
