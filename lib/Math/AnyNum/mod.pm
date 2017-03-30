use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __mod__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;

    Math::GMPq::Rmpq_sgn($y)
      || goto &Math::AnyNum::_nan;

    my $quo = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set($quo, $x);
    Math::GMPq::Rmpq_div($quo, $quo, $y);

    # Floor
    if (!Math::GMPq::Rmpq_integer_p($quo)) {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set_q($z, $quo);
        Math::GMPz::Rmpz_sub_ui($z, $z, 1) if Math::GMPq::Rmpq_sgn($quo) < 0;
        Math::GMPq::Rmpq_set_z($quo, $z);
    }

    Math::GMPq::Rmpq_mul($quo, $quo, $y);
    Math::GMPq::Rmpq_sub($x, $x, $quo);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPq Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpq($_[1]));
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPq Math::MPFR) => sub {
    (@_) = (_mpq2mpfr($_[0]), $_[1]);
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPq Math::MPC) => sub {
    (@_) = (_mpq2mpc($_[0]), $_[1]);
    goto &__mod__;
};

#
## GMPz
#
Class::Multimethods::multimethod __mod__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;

    my $sgn_y = Math::GMPz::Rmpz_sgn($y)
      || goto &Math::AnyNum::_nan;

    Math::GMPz::Rmpz_mod($x, $x, $y);

    if (!Math::GMPz::Rmpz_sgn($x)) {
        ## ok
    }
    elsif ($sgn_y < 0) {
        Math::GMPz::Rmpz_add($x, $x, $y);
    }

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_mod_ui($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPz Math::GMPq) => sub {
    (@_) = (_mpz2mpq($_[0]), $_[1]);
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPz Math::MPFR) => sub {
    (@_) = (_mpz2mpfr($_[0]), $_[1]);
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::GMPz Math::MPC) => sub {
    (@_) = (_mpz2mpc($_[0]), $_[1]);
    goto &__mod__;
};

#
## MPFR
#
Class::Multimethods::multimethod __mod__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;

    Math::MPFR::Rmpfr_fmod($x, $x, $y, $ROUND);

    if (my $sgn_x = Math::MPFR::Rmpfr_sgn($x)) {
        if ($sgn_x > 0 xor Math::MPFR::Rmpfr_sgn($y) > 0) {
            Math::MPFR::Rmpfr_add($x, $x, $y, $ROUND);
        }
    }

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;

    my $quo = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set($quo, $x, $ROUND);
    Math::MPFR::Rmpfr_div_ui($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_floor($quo, $quo);
    Math::MPFR::Rmpfr_mul_ui($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_sub($x, $x, $quo, $ROUND);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;

    my $quo = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set($quo, $x, $ROUND);
    Math::MPFR::Rmpfr_div_q($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_floor($quo, $quo);
    Math::MPFR::Rmpfr_mul_q($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_sub($x, $x, $quo, $ROUND);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;

    my $quo = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set($quo, $x, $ROUND);
    Math::MPFR::Rmpfr_div_z($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_floor($quo, $quo);
    Math::MPFR::Rmpfr_mul_z($quo, $quo, $y, $ROUND);
    Math::MPFR::Rmpfr_sub($x, $x, $quo, $ROUND);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPFR Math::MPC) => sub {
    (@_) = (_mpfr2mpc($_[0]), $_[1]);
    goto &__mod__;
};

#
## MPC
#
Class::Multimethods::multimethod __mod__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;

    my $quo = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set($quo, $x, $ROUND);
    Math::MPC::Rmpc_div($quo, $quo, $y, $ROUND);

    my $real = Math::MPFR::Rmpfr_init2($PREC);
    my $imag = Math::MPFR::Rmpfr_init2($PREC);

    Math::MPC::RMPC_RE($real, $quo);
    Math::MPC::RMPC_IM($imag, $quo);

    Math::MPFR::Rmpfr_floor($real, $real);
    Math::MPFR::Rmpfr_floor($imag, $imag);

    Math::MPC::Rmpc_set_fr_fr($quo, $real, $imag, $ROUND);

    Math::MPC::Rmpc_mul($quo, $quo, $y, $ROUND);
    Math::MPC::Rmpc_sub($x, $x, $quo, $ROUND);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;

    my $quo = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set($quo, $x, $ROUND);
    Math::MPC::Rmpc_div_ui($quo, $quo, $y, $ROUND);

    my $real = Math::MPFR::Rmpfr_init2($PREC);
    my $imag = Math::MPFR::Rmpfr_init2($PREC);

    Math::MPC::RMPC_RE($real, $quo);
    Math::MPC::RMPC_IM($imag, $quo);

    Math::MPFR::Rmpfr_floor($real, $real);
    Math::MPFR::Rmpfr_floor($imag, $imag);

    Math::MPC::Rmpc_set_fr_fr($quo, $real, $imag, $ROUND);

    Math::MPC::Rmpc_mul_ui($quo, $quo, $y, $ROUND);
    Math::MPC::Rmpc_sub($x, $x, $quo, $ROUND);

    $x;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPC Math::MPFR) => sub {
    (@_) = ($_[0], _mpfr2mpc($_[1]));
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPC Math::GMPz) => sub {
    (@_) = ($_[0], _mpz2mpc($_[1]));
    goto &__mod__;
};

Class::Multimethods::multimethod __mod__ => qw(Math::MPC Math::GMPq) => sub {
    (@_) = ($_[0], _mpq2mpc($_[1]));
    goto &__mod__;
};

1;