use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __iroot__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;

    if ($y == 0) {
        Math::GMPz::Rmpz_sgn($x) || return $x;    # 0^Inf = 0

        # 1^Inf = 1 ; (-1)^Inf = 1
        if (Math::GMPz::Rmpz_cmpabs_ui($x, 1) == 0) {
            Math::GMPz::Rmpz_abs($x, $x);
            return $x;
        }

        goto &Math::AnyNum::_inf;
    }
    elsif ($y < 0) {
        my $sign = Math::GMPz::Rmpz_sgn($x) || goto &Math::AnyNum::_inf;    # 1 / 0^k = Inf
        Math::GMPz::Rmpz_cmp_ui($x, 1) == 0 and return $x;                  # 1 / 1^k = 1

        if ($sign < 0) {
            goto &Math::AnyNum::_nan;
        }

        Math::GMPz::Rmpz_set_ui($x, 0);
        return $x;
    }
    elsif ($y % 2 == 0 and Math::GMPz::Rmpz_sgn($x) < 0) {
        goto &Math::AnyNum::_nan;
    }

    Math::GMPz::Rmpz_root($x, $x, $y);
    $x;
};

1;
