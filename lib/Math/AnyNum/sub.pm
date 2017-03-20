use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_sub($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpq($_[1]));
    goto &__sub__;

    #~ my ($x, $y) = @_;
    #~ my $z1 = Math::GMPz::Rmpz_init();
    #~ my $z2 = Math::GMPz::Rmpz_init();
    #~ Math::GMPq::Rmpq_get_num($z1, $x);
    #~ Math::GMPq::Rmpq_get_den($z2, $x);
    #~ Math::GMPz::Rmpz_mul($z2, $z2, $y);
    #~ Math::GMPz::Rmpz_sub($z1, $z1, $z2);
    #~ Math::GMPq::Rmpq_set_num($x, $z1);
    #~ Math::GMPq::Rmpq_canonicalize($x);
    #~ $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__sub__;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__sub__;
};

#
## GMPz
#
Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_sub($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::GMPz::Rmpz_add_ui($x, $x, CORE::abs($y))
      : Math::GMPz::Rmpz_sub_ui($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::GMPq) => sub {
    (@_) = (_mpz2mpq($_[0]), $_[1]);
    goto &__sub__;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__sub__;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__sub__;
};

#
## MPFR
#
Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_add_ui($x, $x, CORE::abs($y), $ROUND)
      : Math::MPFR::Rmpfr_sub_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub_q($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__sub__;
};

#
## MPC
#
Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_sub($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPC::Rmpc_add_ui($x, $x, CORE::abs($y), $ROUND)
      : Math::MPC::Rmpc_sub_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::MPFR) => sub {
    (@_) = ($_[0], _mpfr2mpc($_[1]));
    goto &__sub__;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpc($_[1]));
    goto &__sub__;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpc($_[1]));
    goto &__sub__;
};

1;
