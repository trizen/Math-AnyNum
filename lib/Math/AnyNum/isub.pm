use 5.014;
use warnings;

our ($ROUND, $PREC);

sub __isub__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_sub($x, $x, $y);
    $x;
}
