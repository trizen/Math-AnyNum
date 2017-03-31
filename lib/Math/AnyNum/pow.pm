use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __pow__ => qw(Math::GMPq $) => sub {
    my ($x, $y) = @_;

    if (Math::GMPq::Rmpq_integer_p($x)) {

        my $z = Math::GMPz::Rmpz_init();
        Math::GMPq::Rmpq_numref($z, $x);
        Math::GMPz::Rmpz_pow_ui($z, $z, CORE::abs($y));

        if ($y < 0) {
            if (!Math::GMPz::Rmpz_sgn($z)) {
                my $inf = Math::MPFR::Rmpfr_init2($PREC);
                Math::MPFR::Rmpfr_set_inf($inf, 1);
                return $inf;
            }

            my $q = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_z($q, $z);
            Math::GMPq::Rmpq_inv($q, $q);
            return $q;
        }

        return $z;
    }

    my $q = Math::GMPq::Rmpq_init();
    my $z = Math::GMPz::Rmpz_init();

    Math::GMPq::Rmpq_numref($z, $x);
    Math::GMPz::Rmpz_pow_ui($z, $z, CORE::abs($y));

    Math::GMPq::Rmpq_set_num($q, $z);
    Math::GMPq::Rmpq_denref($z, $x);
    Math::GMPz::Rmpz_pow_ui($z, $z, CORE::abs($y));

    Math::GMPq::Rmpq_set_den($q, $z);
    Math::GMPq::Rmpq_inv($q, $q) if $y < 0;
    return $q;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;

    # Integer power
    if (Math::GMPq::Rmpq_integer_p($y)) {
        (@_) = ($x, Math::GMPq::Rmpq_get_d($y));
        goto &__pow__;
    }

    # (-x)^(a/b) is a complex number
    elsif (Math::GMPq::Rmpq_sgn($x) < 0) {
        (@_) = (_mpq2mpc($x), _mpq2mpfr($y));
        goto &__pow__;
    }

    (@_) = (_mpq2mpfr($x), _mpq2mpfr($y));
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPq Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpq($_[1]));
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__pow__;
};

#
## GMPz
#

Class::Multimethods::multimethod __pow__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;

    Math::GMPz::Rmpz_pow_ui($x, $x, CORE::abs($y));

    if ($y < 0) {
        Math::GMPz::Rmpz_sgn($x) || do {
            my $r = Math::MPFR::Rmpfr_init2($PREC);
            Math::MPFR::Rmpfr_set_inf($r, 1);
            return $r;
        };

        my $q = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set_z($q, $x);
        Math::GMPq::Rmpq_inv($q, $q);
        return $q;
    }

    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPz Math::GMPz) => sub {
    (@_) = ($_[0], Math::GMPz::Rmpz_get_d($_[1]));
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPz Math::GMPq) => sub {
    (@_) = (_mpz2mpq($_[0]), $_[1]);
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__pow__;
};

#
## MPFR
#
Class::Multimethods::multimethod __pow__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;

    if (    Math::MPFR::Rmpfr_sgn($x) < 0
        and !Math::MPFR::Rmpfr_integer_p($y)
        and Math::MPFR::Rmpfr_number_p($y)) {
        (@_) = (_mpfr2mpc($x), $y);
        goto &__pow__;
    }

    Math::MPFR::Rmpfr_pow($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_pow_si($x, $x, $y, $ROUND)
      : Math::MPFR::Rmpfr_pow_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPFR Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpfr($_[1]));
    goto &__pow__;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_pow_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__pow__;
};

#
## MPC
#
Class::Multimethods::multimethod __pow__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_pow($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPC::Rmpc_pow_si($x, $x, $y, $ROUND)
      : Math::MPC::Rmpc_pow_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_pow_fr($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPC Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_pow_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __pow__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpc($_[1]));
    goto &__pow__;
};

1;
