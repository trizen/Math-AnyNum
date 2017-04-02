use 5.014;
use warnings;

our ($ROUND, $PREC);

# hypot(x, y) = sqrt(x^2 + y^2)

Class::Multimethods::multimethod __hypot__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_hypot($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __hypot__ => qw(Math::MPFR Math::MPC) => sub {
    my ($x, $y) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($r, $y, $ROUND);
    Math::MPFR::Rmpfr_hypot($x, $x, $r, $ROUND);
    $x;
};

Class::Multimethods::multimethod __hypot__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($r, $x, $ROUND);
    Math::MPFR::Rmpfr_hypot($r, $r, $y, $ROUND);
    $r;
};

Class::Multimethods::multimethod __hypot__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($r, $x, $ROUND);
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($f, $y, $ROUND);
    Math::MPFR::Rmpfr_hypot($r, $r, $f, $ROUND);
    $r;
};

1;
