use 5.014;
use warnings;

our ($ROUND, $PREC);

#
## GMPq
#
Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_sub($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPq::Rmpq_sub_z($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_q($f, $x, $ROUND);
    Math::MPFR::Rmpfr_sub($f, $f, $y, $ROUND);
    $f;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPq Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $x, $ROUND);
    Math::MPC::Rmpc_sub($c, $c, $y, $ROUND);
    $c;
};

#
## GMPz
#
Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_sub($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::GMPz::Rmpz_add_ui($x, $x, -$y)
      : Math::GMPz::Rmpz_sub_ui($x, $x, $y);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::GMPq) => sub {
    my ($x, $y) = @_;
    my $q = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_z_sub($q, $x, $y);
    $q;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_z($f, $x, $ROUND);
    Math::MPFR::Rmpfr_sub($f, $f, $y, $ROUND);
    $f;
};

Class::Multimethods::multimethod __sub__ => qw(Math::GMPz Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $x, $ROUND);
    Math::MPC::Rmpc_sub($c, $c, $y, $ROUND);
    $c;
};

#
## MPFR
#
Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::MPFR) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPFR::Rmpfr_add_ui($x, $x, -$y, $ROUND)
      : Math::MPFR::Rmpfr_sub_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::GMPq) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub_q($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::GMPz) => sub {
    my ($x, $y) = @_;
    Math::MPFR::Rmpfr_sub_z($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPFR Math::MPC) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_fr($c, $x, $ROUND);
    Math::MPC::Rmpc_sub($c, $c, $y, $ROUND);
    $c;
};

#
## MPC
#
Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::MPC) => sub {
    my ($x, $y) = @_;
    Math::MPC::Rmpc_sub($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC $) => sub {
    my ($x, $y) = @_;
    $y < 0
      ? Math::MPC::Rmpc_add_ui($x, $x, -$y, $ROUND)
      : Math::MPC::Rmpc_sub_ui($x, $x, $y, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::MPFR) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_fr($c, $y, $ROUND);
    Math::MPC::Rmpc_sub($x, $x, $c, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::GMPz) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($c, $y, $ROUND);
    Math::MPC::Rmpc_sub($x, $x, $c, $ROUND);
    $x;
};

Class::Multimethods::multimethod __sub__ => qw(Math::MPC Math::GMPq) => sub {
    my ($x, $y) = @_;
    my $c = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($c, $y, $ROUND);
    Math::MPC::Rmpc_sub($x, $x, $c, $ROUND);
    $x;
};

1;
