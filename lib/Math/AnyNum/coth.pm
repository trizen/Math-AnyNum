use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __coth__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_coth($x, $x, $ROUND);
    $x;
};

# coth(x) = 1/tanh(x)
Class::Multimethods::multimethod __coth__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_tanh($x, $x, $ROUND);
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __coth__ => qw(Math::GMPq) => sub {
    my ($x) = _mpq2mpfr($_[0]);
    Math::MPFR::Rmpfr_coth($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __coth__ => qw(Math::GMPz) => sub {
    my ($x) = _mpz2mpfr($_[0]);
    Math::MPFR::Rmpfr_coth($x, $x, $ROUND);
    $x;
};

1;
