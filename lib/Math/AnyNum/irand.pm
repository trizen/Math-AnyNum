use 5.014;
use warnings;

#
## This multimethod DO NOT modify $x.
#
Class::Multimethods::multimethod __irand__ => qw(Math::GMPz Math::GMPz *) => sub {
    my ($x, $y, $state) = @_;

    my $cmp = Math::GMPz::Rmpz_cmp($y, $x);

    if ($cmp == 0) {
        return Math::GMPz::Rmpz_init_set($x);
    }
    elsif ($cmp < 0) {
        ($x, $y) = ($y, $x);
    }

    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_sub($r, $y, $x);
    Math::GMPz::Rmpz_add_ui($r, $r, 1);
    Math::GMPz::Rmpz_urandomm($r, $state, $r, 1);
    Math::GMPz::Rmpz_add($r, $r, $x);
    $r;
};

#
## This multimethod DO modify $x.
#
Class::Multimethods::multimethod __irand__ => qw(Math::GMPz *) => sub {
    my ($x, $state) = @_;

    my $sgn = Math::GMPz::Rmpz_sgn($x) || do {
        return Math::GMPz::Rmpz_init_set_ui(0);
    };

    if ($sgn < 0) {
        Math::GMPz::Rmpz_sub_ui($x, $x, 1);
    }
    else {
        Math::GMPz::Rmpz_add_ui($x, $x, 1);
    }

    Math::GMPz::Rmpz_urandomm($x, $state, $x, 1);
    Math::GMPz::Rmpz_neg($x, $x) if $sgn < 0;
    $x;
};

1;
