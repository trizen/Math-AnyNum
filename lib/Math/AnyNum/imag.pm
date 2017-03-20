use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __imag__ => qw(Math::MPFR) => sub { $_[0] };
Class::Multimethods::multimethod __imag__ => qw(Math::GMPq) => sub { $_[0] };
Class::Multimethods::multimethod __imag__ => qw(Math::GMPz) => sub { $_[0] };

Class::Multimethods::multimethod __imag__ => qw(Math::MPC) => sub {
    my ($x) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::RMPC_IM($r, $x);
    $r;
};

1;
