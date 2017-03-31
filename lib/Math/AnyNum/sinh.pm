use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __sinh__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_sinh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sinh__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sinh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sinh__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__sinh__;
};

Class::Multimethods::multimethod __sinh__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__sinh__;
};

1;
