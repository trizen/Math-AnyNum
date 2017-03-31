use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __csch__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_csch($x, $x, $ROUND);
    $x;
};

# csch(x) = 1/sinh(x)
Class::Multimethods::multimethod __csch__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sinh($x, $x, $ROUND);
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __csch__ => qw(Math::GMPq) => sub {
    my ($x) = _mpq2mpfr($_[0]);
    Math::MPFR::Rmpfr_csch($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __csch__ => qw(Math::GMPz) => sub {
    my ($x) = _mpz2mpfr($_[0]);
    Math::MPFR::Rmpfr_csch($x, $x, $ROUND);
    $x;
};

1;
