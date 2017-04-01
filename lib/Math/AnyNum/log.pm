use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## MPFR
#

Class::Multimethods::multimethod __log__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Complex for x < 0
    if (Math::MPFR::Rmpfr_sgn($x) < 0) {
        (@_) = _mpfr2mpc($_[0]);
        goto &__log__;
    }

    Math::MPFR::Rmpfr_log($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __log2__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Complex for x < 0
    if (Math::MPFR::Rmpfr_sgn($x) < 0) {
        (@_) = _mpfr2mpc($_[0]);
        goto &__log2__;
    }

    Math::MPFR::Rmpfr_log2($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __log10__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    # Complex for x < 0
    if (Math::MPFR::Rmpfr_sgn($x) < 0) {
        (@_) = _mpfr2mpc($_[0]);
        goto &__log10__;
    }

    Math::MPFR::Rmpfr_log10($x, $x, $ROUND);
    $x;
};

#
## MPC
#

Class::Multimethods::multimethod __log__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_log($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __log2__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    my $ln2 = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_log2($ln2, $ROUND);
    Math::MPC::Rmpc_log($x, $x, $ROUND);
    Math::MPC::Rmpc_div_fr($x, $x, $ln2, $ROUND);
    $x;
};

Class::Multimethods::multimethod __log10__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_log10($x, $x, $ROUND);
    $x;
};

1;
