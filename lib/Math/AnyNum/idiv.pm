use 5.014;
use warnings;

our ($ROUND, $PREC);

sub __idiv__ {          # takes two Math::GMPz objects
    my ($x, $y) = @_;

    # Detect division by zero
    if (!Math::GMPz::Rmpz_sgn($y)) {
        my $sign = Math::GMPz::Rmpz_sgn($x);

        if ($sign == 0) {    # 0/0
            goto &Math::AnyNum::_nan;
        }
        elsif ($sign > 0) {    # x/0 where: x > 0
            goto &Math::AnyNum::_inf;
        }
        else {                 # x/0 where: x < 0
            goto &Math::AnyNum::_ninf;
        }
    }

    Math::GMPz::Rmpz_tdiv_q($x, $x, $y);
    $x;
}
