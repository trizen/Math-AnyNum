use 5.014;
use warnings;

our ($ROUND, $PREC);

sub __valuation__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_sgn($y) || return 0;
    Math::GMPz::Rmpz_remove($x, $x, $y);
}

1;
