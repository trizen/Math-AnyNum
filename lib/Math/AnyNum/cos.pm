use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __cos__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_cos($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __cos__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_cos($x, $x, $ROUND);
    $x;
};

1;
