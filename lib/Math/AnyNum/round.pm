use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __round__ => qw(Math::GMPq $) => sub {
    my ($n, $prec) = @_;

    my $nth = -CORE::int($prec);
    my $sgn = Math::MPFR::Rmpfr_sgn($n);

    Math::GMPq::Rmpq_abs($n, $n) if $sgn < 0;

    my $p = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_str($p, '1' . ('0' x CORE::abs($nth)), 10);

    if ($nth < 0) {
        Math::GMPq::Rmpq_div($n, $n, $p);
    }
    else {
        Math::GMPq::Rmpq_mul($n, $n, $p);
    }

    state $half = do {
        my $q = Math::GMPq::Rmpq_init_nobless();
        Math::GMPq::Rmpq_set_ui($q, 1, 2);
        $q;
    };

    Math::GMPq::Rmpq_add($n, $n, $half);

    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_q($z, $n);

    if (Math::GMPz::Rmpz_odd_p($z) and Math::GMPq::Rmpq_integer_p($n)) {
        Math::GMPz::Rmpz_sub_ui($z, $z, 1);
    }

    Math::GMPq::Rmpq_set_z($n, $z);

    if ($nth < 0) {
        Math::GMPq::Rmpq_mul($n, $n, $p);
    }
    else {
        Math::GMPq::Rmpq_div($n, $n, $p);
    }

    if ($sgn < 0) {
        Math::GMPq::Rmpq_neg($n, $n);
    }

    (@_) = ($n);

    if (Math::GMPq::Rmpq_integer_p($n)) {
        goto &_mpq2mpz;
    }

    goto &_mpq2mpfr;
};

1;
