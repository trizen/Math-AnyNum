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
    (@_) = ($_[0], _mpz2mpq($_[1]));
    goto &__div__;

    #~ # Check for division by zero
    #~ if (Math::GMPz::Rmpz_sgn($_[1]) == 0) {
    #~ (@_) = (_mpq2mpfr($_[0]), $_[1]);
    #~ goto &__div__;
    #~ }

    #~ my ($x, $y) = @_;
    #~ my $z = Math::GMPz::Rmpz_init();
    #~ Math::GMPq::Rmpq_get_den($z, $x);
    #~ Math::GMPz::Rmpz_mul($z, $z, $y);
    #~ Math::GMPq::Rmpq_set_den($x, $z);
    #~ Math::GMPq::Rmpq_canonicalize($x);
    #~ $x;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__div__;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__div__;
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
    (@_) = (_mpz2mpq($_[0]), $_[1]);
    goto &__div__;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__div__;
};

Class::Multimethods::multimethod __div__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__div__;
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
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__div__;
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
        Math::MPC::Rmpc_div_ui($x, $x, CORE::abs($y), $ROUND);
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
    (@_) = ($_[0], _mpz2mpfr($_[1]));
    goto &__div__;
};

Class::Multimethods::multimethod __div__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpfr($_[1]));
    goto &__div__;
};

1;
