use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __neg__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_neg($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __neg__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    Math::GMPq::Rmpq_neg($x, $x);
    $x;
};

Class::Multimethods::multimethod __neg__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
    Math::GMPz::Rmpz_neg($x, $x);
    $x;
};

Class::Multimethods::multimethod __neg__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_neg($x, $x, $ROUND);
    $x;
};

1;
