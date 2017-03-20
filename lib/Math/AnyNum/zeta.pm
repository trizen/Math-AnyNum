use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __zeta__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_zeta($x, $x, $ROUND);
    $x;
};

Class::Multimethods::multimethod __zeta__ => qw(Math::GMPq) => sub {
    (@_) = _mpq2mpfr($_[0]);
    goto &__zeta__;
};

Class::Multimethods::multimethod __zeta__ => qw(Math::GMPz) => sub {
    (@_) = _mpz2mpfr($_[0]);
    goto &__zeta__;
};

1;
