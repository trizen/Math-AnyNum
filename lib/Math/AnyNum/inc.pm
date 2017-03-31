use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __inc__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_add_ui($x, $x, 1, $ROUND);
    $x;
};

Class::Multimethods::multimethod __inc__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    state $ONE = do {
        my $r = Math::GMPq::Rmpq_init_nobless();
        Math::GMPq::Rmpq_set_ui($r, 1, 1);
        $r;
    };
    Math::GMPq::Rmpq_add($x, $x, $ONE);
    $x;
};

Class::Multimethods::multimethod __inc__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
    Math::GMPz::Rmpz_add_ui($x, $x, 1);
    $x;
};

Class::Multimethods::multimethod __inc__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_add_ui($x, $x, 1, $ROUND);
    $x;
};

1;
