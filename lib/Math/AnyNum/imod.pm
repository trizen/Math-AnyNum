use 5.014;
use warnings;

Class::Multimethods::multimethod __imod__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;

    my $sign_y = Math::GMPz::Rmpz_sgn($y)
      || goto &Math::AnyNum::_nan;

    Math::GMPz::Rmpz_mod($x, $x, $y);

    if (!Math::GMPz::Rmpz_sgn($x)) {
        ## OK
    }
    elsif ($sign_y < 0) {
        Math::GMPz::Rmpz_add($x, $x, $y);
    }

    $x;
};

Class::Multimethods::multimethod __imod__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;

    CORE::int($y)
      || goto &Math::AnyNum::_nan;

    my $neg_y = $y < 0;
    $y = -$y if $neg_y;

    Math::GMPz::Rmpz_mod_ui($x, $x, $y);

    if (!Math::GMPz::Rmpz_sgn($x)) {
        ## OK
    }
    elsif ($neg_y) {
        Math::GMPz::Rmpz_sub_ui($x, $x, $y);
    }

    $x;
};

1;
