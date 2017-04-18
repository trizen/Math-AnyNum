use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __norm__ => qw(Math::MPC) => sub {
    my ($x) = @_;
            my $f = Math::MPFR::Rmpfr_init2($PREC);
            Math::MPC::Rmpc_norm($f, $x, $ROUND);
            $f;
};

Class::Multimethods::multimethod __norm__ => qw(Math::MPFR) => sub {
    my ($x) = @_;
 Math::MPFR::Rmpfr_sqr($x, $x, $ROUND);
            $x;
};

Class::Multimethods::multimethod __norm__ => qw(Math::GMPz) => sub {
    my ($x) = @_;
      Math::GMPz::Rmpz_mul($x, $x, $x);
            $x;
};

Class::Multimethods::multimethod __norm__ => qw(Math::GMPq) => sub {
    my ($x) = @_;
 Math::GMPq::Rmpq_mul($x, $x, $x);
            $x;
};

1;
