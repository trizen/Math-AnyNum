use 5.014;
use warnings;

our ($ROUND);

Class::Multimethods::multimethod __sec__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_sec($x, $x, $ROUND);
    $x;
};

# sec(x) = 1/cos(x)
Class::Multimethods::multimethod __sec__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_cos($x, $x, $ROUND);
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

1;
