use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## MPFR
#
Class::Multimethods::multimethod __cmp__ => qw(Math::MPFR Math::MPFR) => sub {
    Math::MPFR::Rmpfr_cmp($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::MPFR Math::GMPz) => sub {
    Math::MPFR::Rmpfr_cmp_z($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::MPFR Math::GMPq) => sub {
    Math::MPFR::Rmpfr_cmp_q($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__cmp__;
};

#
## GMPq
#
Class::Multimethods::multimethod __cmp__ => qw(Math::GMPq Math::GMPq) => sub {
    Math::GMPq::Rmpq_cmp($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::GMPq Math::GMPz) => sub {
    Math::GMPq::Rmpq_cmp_z($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::GMPq Math::MPFR) => sub {
    -(Math::MPFR::Rmpfr_cmp_q($_[1], $_[0]));
};

#~ Class::Multimethods::multimethod __cmp__ => qw(Math::GMPq Math::MPC) => sub {
    #~ (@_) = (_mpq2mpc($_[0]), $_[1]);
    #~ goto &__cmp__;
#~ };

#
## GMPz
#
Class::Multimethods::multimethod __cmp__ => qw(Math::GMPz Math::GMPz) => sub {
    Math::GMPz::Rmpz_cmp($_[0], $_[1]);
};

Class::Multimethods::multimethod __cmp__ => qw(Math::GMPz Math::GMPq) => sub {
     -(Math::GMPq::Rmpq_cmp_z($_[1], $_[0]));
};

Class::Multimethods::multimethod __cmp__ => qw(Math::GMPz Math::MPFR) => sub {
    -(Math::MPFR::Rmpfr_cmp_z($_[1], $_[0]));
};

#~ Class::Multimethods::multimethod __cmp__ => qw(Math::GMPz Math::MPC) => sub {
    #~ (@_) = (_mpz2mpc($_[0]), $_[1]);
    #~ goto &__cmp__;
#~ };

#
## MPC
#
#~ Class::Multimethods::multimethod __cmp__ => qw(Math::MPC Math::MPC) => sub {
    #~ Math::MPC::Rmpc_cmp($_[0], $_[1]);
#~ };

#~ Class::Multimethods::multimethod __cmp__ => qw(Math::MPC Math::GMPz) => sub {
    #~ (@_) = ($_[0], _mpz2mpc($_[1]));
    #~ goto &__cmp__;
#~ };

#~ Class::Multimethods::multimethod __cmp__ => qw(Math::MPC Math::GMPq) => sub {
    #~ (@_) = ($_[0], _mpq2mpc($_[1]));
    #~ goto &__cmp__;
#~ };

#~ Class::Multimethods::multimethod __cmp__ => qw(Math::MPC Math::MPFR) => sub {
    #~ (@_) = ($_[0], _mpfr2mpc($_[1]));
    #~ goto &__cmp__;
#~ };
