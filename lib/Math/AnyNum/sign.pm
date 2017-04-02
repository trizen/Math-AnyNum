use 5.014;
use warnings;

Class::Multimethods::multimethod __sign__ => qw(Math::MPFR) => \&Math::MPFR::Rmpfr_sgn;
Class::Multimethods::multimethod __sign__ => qw(Math::GMPq) => \&Math::GMPq::Rmpq_sgn;
Class::Multimethods::multimethod __sign__ => qw(Math::GMPz) => \&Math::GMPz::Rmpz_sgn;

Class::Multimethods::multimethod __sign__ => qw(Math::MPC) => sub {
    (@_) = _any2mpfr($_[0]);
    goto &__sign__;
};

1;
