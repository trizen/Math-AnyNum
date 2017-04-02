use 5.014;
use warnings;

sub __iadd__ {    # takes two Math::GMPz objects
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_add($x, $x, $y);
    $x;
}

1;
