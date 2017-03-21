use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __abs__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_abs($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __abs__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    Math::GMPq::Rmpq_abs($x, $x);
    $x;
};

Class::Multimethods::multimethod __abs__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
    Math::GMPz::Rmpz_abs($x, $x);
    $x;
};

Class::Multimethods::multimethod __abs__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    my $mpfr = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($mpfr, $x, $ROUND);
    $mpfr;
};
