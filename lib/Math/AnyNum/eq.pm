use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## MPFR
#
Class::Multimethods::multimethod __eq__ => qw(Math::MPFR Math::MPFR) => sub {
    Math::MPFR::Rmpfr_equal_p($_[0], $_[1]);
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPFR Math::GMPz) => sub {
    Math::MPFR::Rmpfr_integer_p($_[0]) && do {
        (@_) = ($_[0], _mpz2mpfr($_[1]));
        goto &__eq__;
    };
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPFR Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpfr($_[1]));
    goto &__eq__;
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__eq__;
};

#
## GMPq
#
Class::Multimethods::multimethod __eq__ => qw(Math::GMPq Math::GMPq) => sub {
    Math::GMPq::Rmpq_equal($_[0], $_[1]);
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPq Math::GMPz) => sub {
    Math::GMPq::Rmpq_integer_p($_[0]) && do {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPq::Rmpq_get_num($z, $_[0]);
        Math::GMPz::Rmpz_cmp($z, $_[1]) == 0;
    };
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__eq__;
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__eq__;
};

#
## GMPz
#
Class::Multimethods::multimethod __eq__ => qw(Math::GMPz Math::GMPz) => sub {
    Math::GMPz::Rmpz_cmp($_[0], $_[1]) == 0;
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPz Math::GMPq) => sub {
    Math::GMPq::Rmpq_integer_p($_[1]) && do {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPq::Rmpq_get_num($z, $_[1]);
        Math::GMPz::Rmpz_cmp($z, $_[0]) == 0;
    };
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__eq__;
};

Class::Multimethods::multimethod __eq__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__eq__;
};

#
## MPC
#
Class::Multimethods::multimethod __eq__ => qw(Math::MPC Math::MPC) => sub {
    Math::MPC::Rmpc_cmp($_[0], $_[1]) == 0;
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPC Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpc($_[1]));
    goto &__eq__;
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpc($_[1]));
    goto &__eq__;
};

Class::Multimethods::multimethod __eq__ => qw(Math::MPC Math::MPFR) => sub {
    (@_) = ($_[0], _mpfr2mpc($_[1]));
    goto &__eq__;
};
