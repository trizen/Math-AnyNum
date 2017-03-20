use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __numify__ => qw(Math::MPFR) => sub {
    Math::MPFR::Rmpfr_get_d($_[0], $ROUND);
};

Class::Multimethods::multimethod __numify__ => qw(Math::GMPq) => sub {
    Math::GMPq::Rmpq_get_d($_[0]);
};

Class::Multimethods::multimethod __numify__ => qw(Math::GMPz) => sub {
    Math::GMPz::Rmpz_get_d($_[0]);
};

Class::Multimethods::multimethod __numify__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::RMPC_RE($r, $x);
    Math::MPFR::Rmpfr_get_d($r, $ROUND);
};

1;
