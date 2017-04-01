use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __cot__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_cot($x, $x, $ROUND);
    $x;
};

# cot(x) = 1/tan(x)
Class::Multimethods::multimethod __cot__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_tan($x, $x, $ROUND);
    Math::MPC::Rmpc_ui_div($x, 1, $x, $ROUND);
    $x;
};

1;
