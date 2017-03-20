use 5.014;
use warnings;

our ($ROUND, $PREC);

Class::Multimethods::multimethod __ => qw(Math::MPFR) => sub {
    my ($x) = @_;

};

Class::Multimethods::multimethod __ => qw(Math::GMPq) => sub {
    my ($x) = @_;

};

Class::Multimethods::multimethod __ => qw(Math::GMPz) => sub {
    my ($x) = @_;

};

Class::Multimethods::multimethod __ => qw(Math::MPC) => sub {
    my ($x) = @_;

};
