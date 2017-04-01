use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __atan2__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_atan2($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __atan2__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__atan2__;
};

# atan2(x, y) = atan(x/y)
Class::Multimethods::multimethod __atan2__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_div_fr($x, $x, $y, $ROUND);
    Math::MPC::Rmpc_atan($x, $x, $ROUND);
    $x;
};

# atan2(x, y) = atan(x/y)
Class::Multimethods::multimethod __atan2__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_div($x, $x, $y, $ROUND);
    Math::MPC::Rmpc_atan($x, $x, $ROUND);
    $x;
};

1;
