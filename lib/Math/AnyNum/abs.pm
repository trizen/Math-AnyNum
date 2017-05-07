use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __abs__ => qw(Math::MPFR) => sub {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_abs($r, $_[0], $ROUND);
    $r;
};

Class::Multimethods::multimethod __abs__ => qw(Math::GMPq) => sub {
    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_abs($r, $_[0]);
    $r;
};

Class::Multimethods::multimethod __abs__ => qw(Math::GMPz) => sub {
    my $r = Math::GMPz::Rmpz_init_set($_[0]);
    Math::GMPz::Rmpz_abs($r, $r);
    $r;
};

Class::Multimethods::multimethod __abs__ => qw(Math::MPC) => sub {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::Rmpc_abs($r, $_[0], $ROUND);
    $r;
};

1;
