use 5.014;
use warnings;

our ($ROUND, $PREC);

sub __imul__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_mul($x, $x, $y);
    $x;
}
