use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __add__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_add($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPq Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_add_z($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPq Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_add_q($f, $y, $x, $ROUND);
    $f;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPq Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $x, $ROUND);
    Math::MPC::Rmpc_add($c, $c, $y, $ROUND);
    $c;
};

#
## GMPz
#
Class::Multimethods::multimethod __add__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_add($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::GMPz::Rmpz_sub_ui($x, $x, -$y)
      : Math::GMPz::Rmpz_add_ui($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPz Math::GMPq) => sub {
    my ($x, $y) = @_;
    my $q = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_add_z($q, $y, $x);
    $q;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPz Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_add_z($f, $y, $x, $ROUND);
    $f;
};

Class::Multimethods::multimethod __add__ => qw(Math::GMPz Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $x, $ROUND);
    Math::MPC::Rmpc_add($c, $c, $y, $ROUND);
    $c;
};

#
## MPFR
#
Class::Multimethods::multimethod __add__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_add($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_sub_ui($x, $x, -$y, $ROUND)
      : Math::MPFR::Rmpfr_add_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_add_q($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_add_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPFR Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set($c, $y, $ROUND);
    Math::MPC::Rmpc_add_fr($c, $c, $x, $ROUND);
    $c;
};

#
## MPC
#
Class::Multimethods::multimethod __add__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_add($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPC::Rmpc_sub_ui($x, $x, -$y, $ROUND)
      : Math::MPC::Rmpc_add_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_add_fr($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPC Math::GMPz) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $y, $ROUND);
    Math::MPC::Rmpc_add($x, $x, $c, $ROUND);
    $x;
};

Class::Multimethods::multimethod __add__ => qw(Math::MPC Math::GMPq) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $y, $ROUND);
    Math::MPC::Rmpc_add($x, $x, $c, $ROUND);
    $x;
};

1;
