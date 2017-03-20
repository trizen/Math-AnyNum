use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __copy__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set($r, $x, $ROUND);
    $r;
};

Class::Multimethods::multimethod __copy__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set($r, $x);
    $r;
};

Class::Multimethods::multimethod __copy__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set($r, $x);
    $r;
};

Class::Multimethods::multimethod __copy__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    my $r = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set($r, $x, $ROUND);
    $r;
};
