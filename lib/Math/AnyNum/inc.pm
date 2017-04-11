use 5.014;
use warnings;

our ($ROUND);

Class::Multimethods::multimethod __inc__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    Math::MPFR::Rmpfr_add_ui($x, $x, 1, $ROUND);
    $x;
};

Class::Multimethods::multimethod __inc__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    state $one = Math::GMPz::Rmpz_init_set_ui_nobless(1);
    Math::GMPq::Rmpq_add_z($x, $x, $one);
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
