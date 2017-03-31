use 5.014;
use warnings;

our ($ROUND, $PREC);

# acsch(x) = asinh(1/x)
Class::Multimethods::multimethod __acsch__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_ui_div($x, 1, $x, $ROUND);
    Math::MPFR::Rmpfr_asinh($x, $x, $ROUND);
    $x;
};

# acsch(x) = asinh(1/x)
Class::Multimethods::multimethod __acsch__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    Math::MPC::Rmpc_asinh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __acsch__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__acsch__;
};

Class::Multimethods::multimethod __acsch__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__acsch__;
};

1;
