use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __csc__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_csc($x, $x, $ROUND);
    $x;
};

# csc(x) = 1/sin(x)
Class::Multimethods::multimethod __csc__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sin($x, $x, $ROUND);
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __csc__ => qw(Math::GMPq) => sub {
    my ($x) = _mpq2mpfr($_[0]);
    Math::MPFR::Rmpfr_csc($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __csc__ => qw(Math::GMPz) => sub {
    my ($x) = _mpz2mpfr($_[0]);
    Math::MPFR::Rmpfr_csc($x, $x, $ROUND);
    $x;
};

1;
