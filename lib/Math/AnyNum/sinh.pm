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
    my ($x) = _mpq2mpfr($_[0]);
    Math::MPFR::Rmpfr_sinh($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sinh__ => qw(Math::GMPz) => sub {
    my ($x) = _mpz2mpfr($_[0]);
    Math::MPFR::Rmpfr_sinh($x, $x, $ROUND);
    $x;
};

1;
