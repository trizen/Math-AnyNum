use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;

    # Check for division by zero
    Math::GMPq::Rmpq_sgn($y) || do {
        (@_) = (_mpq2mpfr($x), $y);
        goto &__div__;
    };

    Math::GMPq::Rmpq_div($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::GMPz) => sub {
    my ($x, $y) = @_;

    # Check for division by zero
    Math::GMPz::Rmpz_sgn($y) || do {
        (@_) = (_mpq2mpfr($x), $y);
        goto &__div__;
    };

    my $q = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_z($q, $y);
    Math::GMPq::Rmpq_div($x, $x, $q);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_q($f, $x, $ROUND);
    Math::MPFR::Rmpfr_div($f, $f, $y, $ROUND);
    $f;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $x, $ROUND);
    Math::MPC::Rmpc_div($c, $c, $y, $ROUND);
    $c;
};

#
## GMPz
#
Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;

    # Check for division by zero
    Math::GMPz::Rmpz_sgn($y) || do {
        (@_) = (_mpz2mpfr($x), $y);
        goto &__div__;
    };

    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_num($r, $x);
    Math::GMPq::Rmpq_set_den($r, $y);
    Math::GMPq::Rmpq_canonicalize($r);
    $r;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::GMPq) => sub {
    my ($x, $y) = @_;

    # Check for division by zero
    Math::GMPq::Rmpq_sgn($y) || do {
        (@_) = (_mpz2mpfr($x), $y);
        goto &__div__;
    };

    my $q = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_z($q, $x);
    Math::GMPq::Rmpq_div($q, $q, $y);
    $q;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_z($f, $x, $ROUND);
    Math::MPFR::Rmpfr_div($f, $f, $y, $ROUND);
    $f;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $x, $ROUND);
    Math::MPC::Rmpc_div($c, $c, $y, $ROUND);
    $c;
};

#
## MPFR
#
Class::Multimethods::multimethod __div__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_div($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_div_si($x, $x, $y, $ROUND)
      : Math::MPFR::Rmpfr_div_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_div_q($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_div_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPFR Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_fr($c, $x, $ROUND);
    Math::MPC::Rmpc_div($c, $c, $y, $ROUND);
    $c;
};

#
## MPC
#
Class::Multimethods::multimethod __div__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_div($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    if ($y < 0) {
        Math::MPC::Rmpc_div_ui($x, $x, -$y, $ROUND);
        Math::MPC::Rmpc_neg($x, $x, $ROUND);
    }
    else {
        Math::MPC::Rmpc_div_ui($x, $x, $y, $ROUND);
    }
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_div_fr($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPC Math::GMPz) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $y, $ROUND);
    Math::MPC::Rmpc_div($x, $x, $c, $ROUND);
    $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPC Math::GMPq) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $y, $ROUND);
    Math::MPC::Rmpc_div($x, $x, $c, $ROUND);
    $x;
};

1;
