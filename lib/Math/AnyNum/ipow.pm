use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __ipow__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;

    Math::GMPz::Rmpz_pow_ui($x, $x, CORE::abs($y));

    if ($y < 0) {
        Math::GMPz::Rmpz_sgn($x) || goto &Math::AnyNum::_inf;    # 0^(-y) = Inf
        state $ONE_Z = Math::GMPz::Rmpz_init_set_ui_nobless(1);
        Math::GMPz::Rmpz_tdiv_q($x, $ONE_Z, $x);
    }

    $x;
};

1;
