use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __sin__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_sin($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sin__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sin($x, $x, $ROUND);
    $x;
};

1;
