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
    state $one = Math::GMPz::Rmpz_init_set_ui_nobless(1);
    Math::GMPq::Rmpq_sub_z($x, $x, $one);
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
