use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __stringify__ => qw(Math::MPFR) => sub {
    my ($x) = @_;

    if (!Math::MPFR::Rmpfr_number_p($x)) {
        Math::MPFR::Rmpfr_nan_p($x) ? 'NaN' : (Math::MPFR::Rmpfr_sgn($x) < 0 ? '-Inf' : 'Inf');
    }
    else {
        # log(10)/log(2) =~ 3.3219280948873623
        my $digits = CORE::int($PREC / 3.4);
        my $str = Math::MPFR::Rmpfr_get_str($x, 10, $digits, $ROUND);

        if ($str =~ s/e(-?[0-9]+)\z//) {
            my $exp = $1;

            my $sgn = '';
            if (substr($str, 0, 1) eq '-') {
                $sgn = '-';
                substr($str, 0, 1, '');
            }

            my ($before, $after) = split(/\./, $str);

            if ($exp > 0) {
                if ($exp >= CORE::length($after)) {
                    $after = '.' . $after . "e$exp";
                }
                else {
                    substr($after, $exp, 0, '.');
                }
            }
            else {
                if (CORE::abs($exp) >= CORE::length($before)) {

                    my $diff = CORE::abs($exp) - CORE::length($before);

                    if ($diff <= $digits) {
                        $before = ('0' x (CORE::abs($exp) - CORE::length($before) + 1)) . $before;
                        substr($before, $exp, 0, '.');
                    }
                    else {
                        $before .= '.';
                        $after  .= "e$exp";
                    }
                }
            }

            $str = $sgn . $before . $after;
        }

        $str =~ s/0+\z//;
        $str =~ s/\.\z//;

        (!$str or $str eq '-') ? '0' : $str;
    }

};

Class::Multimethods::multimethod __stringify__ => qw(Math::GMPq) => sub {
    my ($x) = @_;

    Math::GMPq::Rmpq_get_str($x, 10);

    #~ Math::GMPq::Rmpq_integer_p($x)
    #~ ? Math::GMPq::Rmpq_get_str($x, 10)
    #~ : do {
    #~ $PREC = CORE::int($PREC) if ref($PREC);

    #~ my $prec = CORE::int($PREC / 4);
    #~ my $sgn  = Math::GMPq::Rmpq_sgn($x);

    #~ my $n = Math::GMPq::Rmpq_init();
    #~ Math::GMPq::Rmpq_set($n, $x);
    #~ Math::GMPq::Rmpq_abs($n, $n) if $sgn < 0;

    #~ my $p = Math::GMPq::Rmpq_init();
    #~ Math::GMPq::Rmpq_set_str($p, '1' . ('0' x CORE::abs($prec)), 10);

    #~ if ($prec < 0) {
    #~ Math::GMPq::Rmpq_div($n, $n, $p);
    #~ }
    #~ else {
    #~ Math::GMPq::Rmpq_mul($n, $n, $p);
    #~ }

    #~ state $half = do {
    #~ my $q = Math::GMPq::Rmpq_init_nobless();
    #~ Math::GMPq::Rmpq_set_ui($q, 1, 2);
    #~ $q;
    #~ };

    #~ my $z = Math::GMPz::Rmpz_init();
    #~ Math::GMPq::Rmpq_add($n, $n, $half);
    #~ Math::GMPz::Rmpz_set_q($z, $n);

    #~ # Too much rounding... Give up and return an MPFR stringified number.
    #~ !Math::GMPz::Rmpz_sgn($z) && $PREC >= 2 && do {
    #~ my $mpfr = Math::MPFR::Rmpfr_init2($PREC);
    #~ Math::MPFR::Rmpfr_set_q($mpfr, $x, $ROUND);
    #~ return Math::MPFR::Rmpfr_get_str($mpfr, 10, $prec, $ROUND);
    #~ };

    #~ if (Math::GMPz::Rmpz_odd_p($z) and Math::GMPq::Rmpq_integer_p($n)) {
    #~ Math::GMPz::Rmpz_sub_ui($z, $z, 1);
    #~ }

    #~ Math::GMPq::Rmpq_set_z($n, $z);

    #~ if ($prec < 0) {
    #~ Math::GMPq::Rmpq_mul($n, $n, $p);
    #~ }
    #~ else {
    #~ Math::GMPq::Rmpq_div($n, $n, $p);
    #~ }

    #~ my $num = Math::GMPz::Rmpz_init();
    #~ my $den = Math::GMPz::Rmpz_init();

    #~ Math::GMPq::Rmpq_numref($num, $n);
    #~ Math::GMPq::Rmpq_denref($den, $n);

    #~ my @r;
    #~ while (1) {
    #~ Math::GMPz::Rmpz_div($z, $num, $den);
    #~ push @r, Math::GMPz::Rmpz_get_str($z, 10);

    #~ Math::GMPz::Rmpz_mul($z, $z, $den);
    #~ Math::GMPz::Rmpz_sub($num, $num, $z);
    #~ last if !Math::GMPz::Rmpz_sgn($num);

    #~ my $s = -1;
    #~ while (Math::GMPz::Rmpz_cmp($den, $num) > 0) {
    #~ Math::GMPz::Rmpz_mul_ui($num, $num, 10);
    #~ ++$s;
    #~ }

    #~ push(@r, '0' x $s) if ($s > 0);
    #~ }

    #~ ($sgn < 0 ? "-" : '') . shift(@r) . (('.' . join('', @r)) =~ s/0+\z//r =~ s/\.\z//r);
    #~ }
};

Class::Multimethods::multimethod __stringify__ => qw(Math::MPC) => sub {
    my ($x) = @_;

    my $real = Math::MPFR::Rmpfr_init2($PREC);
    my $imag = Math::MPFR::Rmpfr_init2($PREC);

    Math::MPC::RMPC_RE($real, $x);
    Math::MPC::RMPC_IM($imag, $x);

    my $re = __stringify__($real);
    my $im = __stringify__($imag);

    if ($im eq '0' or $im eq '-0') {
        return $re;
    }

    my $sign = '+';

    if (substr($im, 0, 1) eq '-') {
        $sign = '-';
        substr($im, 0, 1, '');
    }

    $im = '' if $im eq '1';
    $re eq '0' ? $sign eq '+' ? "${im}i" : "$sign${im}i" : "$re$sign${im}i";
};

Class::Multimethods::multimethod __stringify__ => qw(Math::GMPz) => sub {
    Math::GMPz::Rmpz_get_str($_[0], 10);
};

1;
