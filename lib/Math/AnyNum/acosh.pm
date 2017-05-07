use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __acosh__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Return a complex number for x < 1
    if (Math::MPFR::Rmpfr_cmp_ui($x, 1) < 0) {
        $x = _mpfr2mpc($x);
        Math::MPC::Rmpc_acosh($x, $x, $ROUND);
        return $x;
    }

    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_acosh($r, $x, $ROUND);
    $r;
};

Class::Multimethods::multimethod __acosh__ => qw(Math::MPC) => sub {
    my $r = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_acosh($r, $_[0], $ROUND);
    $r;
};

1;
