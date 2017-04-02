use 5.014;
use warnings;

our ($ROUND);

sub agm {    # takes two Math::MPFR objects
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_agm($x, $x, $y, $ROUND);
    $x;
}

1;
