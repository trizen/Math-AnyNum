use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __mul__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_mul($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPq Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpq($_[1]));
    goto &__mul__;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__mul__;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__mul__;
};

#
## GMPz
#
Class::Multimethods::multimethod __mul__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_mul($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::GMPz::Rmpz_mul_si($x, $x, $y)
      : Math::GMPz::Rmpz_mul_ui($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPz Math::GMPq) => sub {
    (@_) = (_mpz2mpq($_[0]), $_[1]);
    goto &__mul__;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__mul__;
};

Class::Multimethods::multimethod __mul__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__mul__;
};

#
## MPFR
#
Class::Multimethods::multimethod __mul__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_mul($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_mul_si($x, $x, $y, $ROUND)
      : Math::MPFR::Rmpfr_mul_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_mul_q($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_mul_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__mul__;
};

#
## MPC
#
Class::Multimethods::multimethod __mul__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_mul($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPC::Rmpc_mul_si($x, $x, $y, $ROUND)
      : Math::MPC::Rmpc_mul_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_mul_fr($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPC Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpfr($_[1]));
    goto &__mul__;
};

Class::Multimethods::multimethod __mul__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpfr($_[1]));
    goto &__mul__;
};

1;
