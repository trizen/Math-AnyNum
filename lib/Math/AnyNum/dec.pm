use 5.014;
use warnings;

our ($ROUND);

Class::Multimethods::multimethod __dec__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_sub_ui($x, $x, 1, $ROUND);
    $x;
};

Class::Multimethods::multimethod __dec__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    state $ONE = do {
        my $r = Math::GMPq::Rmpq_init_nobless();
        Math::GMPq::Rmpq_set_ui($r, 1, 1);
        $r;
    };
    Math::GMPq::Rmpq_sub($x, $x, $ONE);
    $x;
};

Class::Multimethods::multimethod __dec__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
    Math::GMPz::Rmpz_sub_ui($x, $x, 1);
    $x;
};

Class::Multimethods::multimethod __dec__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    Math::MPC::Rmpc_sub_ui($x, $x, 1, $ROUND);
    $x;
};

1;
