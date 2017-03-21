package Math::AnyNum;

use 5.014;
use strict;
use warnings;

no warnings qw(numeric);

use Math::MPFR qw();
use Math::GMPq qw();
use Math::GMPz qw();
use Math::MPC qw();

use POSIX qw(ULONG_MAX LONG_MIN);

use Class::Multimethods qw();

=head1 NAME

Math::AnyNum - Transparent interface to Math::GMPq, Math::GMPz, Math::MPFR and Math::MPC.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Math::AnyNum provides a transparent and easy-to-use interface to L<Math::GMPq>, L<Math::GMPz>, L<Math::MPFR> and L<Math::MPC>.

    use Math::AnyNum qw(:constant i);

    say sqrt(-1);       # => i
    say 3+4*i;          # => 3+4i
    say 40->fac         # => 815915283247897734345611269596115894272000000000

=head1 EXPORT

...

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

our ($ROUND, $PREC);

BEGIN {
    $ROUND = Math::MPFR::MPFR_RNDN();
    $PREC  = 200;
}

state $ZERO_F = (Math::MPFR::Rmpfr_init_set_ui_nobless(0, $ROUND))[0];

#~ state $MONE = do {
#~ my $r = Math::GMPq::Rmpq_init_nobless();
#~ Math::GMPq::Rmpq_set_si($r, -1, 1);
#~ $r;
#~ };

#~ state $ZERO = do {
#~ my $r = Math::GMPq::Rmpq_init_nobless();
#~ Math::GMPq::Rmpq_set_ui($r, 0, 1);
#~ $r;
#~ };

#~ state $ONE = do {
#~ my $r = Math::GMPq::Rmpq_init_nobless();
#~ Math::GMPq::Rmpq_set_ui($r, 1, 1);
#~ $r;
#~ };

#~ state $ONE_Z = Math::GMPz::Rmpz_init_set_ui_nobless(1);

use overload
  '""' => \&stringify,
  '0+' => \&numify,
  bool => \&boolify,

  '=' => \&copy,

  # Some shortcuts for speed
  '+='  => sub { $_[0]->add($_[1]) },
  '-='  => sub { $_[0]->sub($_[1]) },
  '*='  => sub { $_[0]->mul($_[1]) },
  '/='  => sub { $_[0]->div($_[1]) },
  '%='  => sub { $_[0]->mod($_[1]) },
  '**=' => sub { $_[0]->pow($_[1]) },

  '^='  => sub { $_[0]->xor($_[1]) },
  '&='  => sub { $_[0]->and($_[1]) },
  '|='  => sub { $_[0]->ior($_[1]) },
  '<<=' => sub { $_[0]->lsft($_[1]) },
  '>>=' => sub { $_[0]->rsft($_[1]) },

  '+' => sub { $_[0]->copy->add($_[1]) },
  '*' => sub { $_[0]->copy->mul($_[1]) },

  '==' => sub { $_[0]->eq($_[1]) },
  '!=' => sub { $_[0]->ne($_[1]) },

  '&' => sub { $_[0]->copy->and($_[1]) },
  '|' => sub { $_[0]->copy->ior($_[1]) },
  '^' => sub { $_[0]->copy->xor($_[1]) },
  '~' => sub { $_[0]->copy->not },

  '++' => \&inc,
  '--' => \&dec,

  '>'   => sub { Math::AnyNum::gt($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '>='  => sub { Math::AnyNum::ge($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<'   => sub { Math::AnyNum::lt($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<='  => sub { Math::AnyNum::le($_[2]  ? ($_[1], $_[0]) : ($_[0], $_[1])) },
  '<=>' => sub { Math::AnyNum::cmp($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  '>>' => sub { Math::AnyNum::rsft($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },
  '<<' => sub { Math::AnyNum::lsft($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },

  '**' => sub { Math::AnyNum::pow($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },
  '%'  => sub { Math::AnyNum::mod($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },

  '/' => sub { $_[2] ? Math::AnyNum::mul($_[0]->copy->inv, $_[1]) : Math::AnyNum::div($_[0]->copy, $_[1]) },
  '-' => sub { $_[2] ? Math::AnyNum::add($_[0]->copy->neg, $_[1]) : Math::AnyNum::sub($_[0]->copy, $_[1]) },

  atan2 => sub { Math::AnyNum::atan2($_[2] ? (__PACKAGE__->new($_[1]), $_[0]) : ($_[0]->copy, $_[1])) },

  eq => sub { "$_[0]" eq "$_[1]" },
  ne => sub { "$_[0]" ne "$_[1]" },

  cmp => sub { $_[2] ? "$_[1]" cmp $_[0]->stringify : $_[0]->stringify cmp "$_[1]" },

  neg  => sub { $_[0]->copy->neg },
  sin  => sub { $_[0]->copy->sin },
  cos  => sub { $_[0]->copy->cos },
  exp  => sub { $_[0]->copy->exp },
  log  => sub { $_[0]->copy->log },
  int  => sub { $_[0]->copy->int },
  abs  => sub { $_[0]->copy->abs },
  sqrt => sub { $_[0]->copy->sqrt };

{

    my %constants = (
                     e   => \&e,
                     phi => \&phi,
                     tau => \&tau,
                     pi  => \&pi,
                     Y   => \&Y,
                     i   => \&i,
                     G   => \&G,
                     Inf => \&inf,
                     NaN => \&nan,
                    );

    sub import {
        shift;

        my $caller = caller(0);

        while (@_) {
            my $name = shift(@_);

            if ($name eq ':constant') {
                overload::constant
                  integer => sub { __PACKAGE__->new_ui($_[0]) },
                  float   => sub { __PACKAGE__->new($_[0], 10) },
                  binary => sub {
                    my ($const) = @_;
                    my $prefix = substr($const, 0, 2);
                        $prefix eq '0x' ? __PACKAGE__->new(substr($const, 2), 16)
                      : $prefix eq '0b' ? __PACKAGE__->new(substr($const, 2), 2)
                      :                   __PACKAGE__->new(substr($const, 1), 8);
                  },
                  ;

                # Export 'Inf' and 'NaN' as constants
                no strict 'refs';

                my $inf_sub = $caller . '::' . 'Inf';
                if (!defined &$inf_sub) {
                    my $inf = inf();
                    *$inf_sub = sub () { $inf };
                }

                my $nan_sub = $caller . '::' . 'NaN';
                if (!defined &$nan_sub) {
                    my $nan = nan();
                    *$nan_sub = sub () { $nan };
                }
            }
            elsif (exists $constants{$name}) {
                no strict 'refs';
                my $caller_sub = $caller . '::' . $name;
                if (!defined &$caller_sub) {
                    my $sub   = $constants{$name};
                    my $value = Math::AnyNum->$sub;
                    *$caller_sub = sub() { $value }
                }
            }
            elsif ($name eq ':all') {
                push @_, keys(%constants);
            }
            elsif ($name eq 'PREC') {
                my $prec = CORE::int(shift(@_));
                if ($prec < 2 or $prec > Math::MPFR::MPFR_PREC_MAX()) {
                    die "invalid value for <<PREC>>: must be between 2 and ", Math::MPFR::MPFR_PREC_MAX();
                }
                $Math::AnyNum::PREC = $prec;
            }
            else {
                die "unknown import: <<$name>>";
            }
        }
        return;
    }

    sub unimport {
        overload::remove_constant('binary', '', 'float', '', 'integer');
    }
}

# Converts a string representing a floating-point number into a rational representation
# Example: "1.234" is converted into "1234/1000"
sub _str2rat {
    my $str = $_[0] || "0";

    my $sign = substr($str, 0, 1);

    if ($sign eq '-') {
        substr($str, 0, 1, '');
        $sign = '-';
    }
    else {
        substr($str, 0, 1, '') if ($sign eq '+');
        $sign = '';
    }

    #~ my $i;
    #~ if (($i = index($str, 'e')) != -1) {

    #~ my $exp = substr($str, $i + 1);

    #~ # Handle specially numbers with very big exponents
    #~ # (it's not a very good solution, but I hope it's only temporarily)
    #~ if (CORE::abs($exp) >= 1000000) {
    #~ my $mpfr = Math::MPFR::Rmpfr_init2($PREC);
    #~ Math::MPFR::Rmpfr_set_str($mpfr, "$sign$str", 10, $ROUND);
    #~ my $mpq = Math::GMPq::Rmpq_init();
    #~ Math::MPFR::Rmpfr_get_q($mpq, $mpfr);
    #~ return Math::GMPq::Rmpq_get_str($mpq, 10);
    #~ }

    #~ my ($before, $after) = split(/\./, substr($str, 0, $i));

    #~ if (!defined($after)) {    # return faster for numbers like "13e2"
    #~ if ($exp >= 0) {
    #~ return ("$sign$before" . ('0' x $exp));
    #~ }
    #~ else {
    #~ $after = '';
    #~ }
    #~ }

    #~ my $numerator   = "$before$after";
    #~ my $denominator = "1";

    #~ if ($exp < 1) {
    #~ $denominator .= '0' x (CORE::abs($exp) + CORE::length($after));
    #~ }
    #~ else {
    #~ my $diff = ($exp - CORE::length($after));
    #~ if ($diff >= 0) {
    #~ $numerator .= '0' x $diff;
    #~ }
    #~ else {
    #~ my $s = "$before$after";
    #~ substr($s, $exp + CORE::length($before), 0, '.');
    #~ return _str2rat("$sign$s");
    #~ }
    #~ }

    #~ "$sign$numerator/$denominator";
    #~ }
    #~ els
    if ((my $i = index($str, '.')) != -1) {
        my ($before, $after) = (substr($str, 0, $i), substr($str, $i + 1));
        if ($after =~ tr/0// == CORE::length($after)) {
            return "$sign$before";
        }
        $sign . ("$before$after/1" =~ s/^0+//r) . ('0' x CORE::length($after));
    }
    else {
        "$sign$str";
    }
}

#~ # Converts a string into an mpfr object
#~ sub _str2mpfr {
#~ my $r = Math::MPFR::Rmpfr_init2($PREC);

#~ if (CORE::int($_[0]) eq $_[0] and $_[0] >= LONG_MIN and $_[0] <= ULONG_MAX) {
#~ $_[0] >= 0
#~ ? Math::MPFR::Rmpfr_set_ui($r, $_[0], $ROUND)
#~ : Math::MPFR::Rmpfr_set_si($r, $_[0], $ROUND);
#~ }
#~ else {
#~ Math::MPFR::Rmpfr_set_str($r, $_[0], 10, $ROUND) && return;
#~ }

#~ $r;
#~ }

# Converts a string into an mpq object
sub _str2obj {
    my ($s) = @_;

    $s || do {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set_ui($r, 0);
        return $r;
    };

    $s = lc($s);

    if ($s eq 'inf' or $s eq '+inf') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, 1);
        return $r;
    }
    elsif ($s eq '-inf') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, -1);
        return $r;
    }
    elsif ($s eq 'nan') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        return $r;
    }

    # Remove underscores
    $s =~ tr/_//d;

    # Performance improvement for Perl integers
    if (CORE::int($s) eq $s and $s >= LONG_MIN and $s <= ULONG_MAX) {
        my $r = Math::GMPz::Rmpz_init();

        $s >= 0
          ? Math::GMPz::Rmpz_set_ui($r, $s)
          : Math::GMPz::Rmpz_set_si($r, $s);

        return $r;
    }

    # Floating-point exponential
    if (index($s, 'e') != -1) {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        if (Math::MPFR::Rmpfr_set_str($r, $s, 10, $ROUND)) {
            Math::MPFR::Rmpfr_set_nan($r);
        }
        return $r;
    }

    if (index($s, '.') != -1) {
        my $rat = _str2rat($s);

        # Not a valid number
        if ($rat !~ m{^\s*[-+]?[0-9]+(?>\s*/\s*[-+]?[1-9]+[0-9]*)?\s*\z}) {
            my $r = Math::MPFR::Rmpfr_init2($PREC);
            if (Math::MPFR::Rmpfr_set_str($r, $s, 10, $ROUND)) {
                Math::MPFR::Rmpfr_set_nan($r);
            }
            return $r;
        }

        # Rational number (a/b)
        if (index($rat, '/') != -1) {
            my $r = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_str($r, $rat, 10);
            Math::GMPq::Rmpq_canonicalize($r);
            return $r;
        }

        # For values like 42.000
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set_str($r, $rat, 10);
        return $r;
    }

    my $r = Math::GMPz::Rmpz_init();
    eval { Math::GMPz::Rmpz_set_str($r, $s, 10); 1 } // do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        return $r;
    };
    return $r;
}

# Converts a string into an mpz object
sub _str2mpz {
    (CORE::int($_[0]) eq $_[0] and $_[0] <= ULONG_MAX and $_[0] >= LONG_MIN)
      ? (
         ($_[0] >= 0)
         ? Math::GMPz::Rmpz_init_set_ui($_[0])
         : Math::GMPz::Rmpz_init_set_si($_[0])
        )
      : eval { Math::GMPz::Rmpz_init_set_str($_[0], 10) };
}

#~ # Converts a AnyNum object to mpfr
#~ sub _big2mpfr {

#~ $PREC = CORE::int($PREC) if ref($PREC);

#~ my $r = Math::MPFR::Rmpfr_init2($PREC);
#~ Math::MPFR::Rmpfr_set_q($r, ${$_[0]}, $ROUND);
#~ $r;
#~ }

#~ # Converts a AnyNum object to mpz
#~ sub _big2mpz {
#~ my $z = Math::GMPz::Rmpz_init();
#~ Math::GMPz::Rmpz_set_q($z, ${$_[0]});
#~ $z;
#~ }

#~ # Converts an integer AnyNum object to mpz
#~ sub _int2mpz {
#~ my $z = Math::GMPz::Rmpz_init();
#~ Math::GMPq::Rmpq_numref($z, ${$_[0]});
#~ $z;
#~ }

#
## MPZ
#
sub _mpz2mpq {
    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_z($r, $_[0]);
    $r;
}

sub _mpz2mpfr {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_z($r, $_[0], $ROUND);
    $r;
}

sub _mpz2mpc {
    my $r = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_z($r, $_[0], $ROUND);
    $r;
}

#
## MPQ
#

sub _mpq2mpz {
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_q($z, $_[0]);
    $z;
}

sub _mpq2mpfr {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_q($r, $_[0], $ROUND);
    $r;
}

sub _mpq2mpc {
    my $r = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_q($r, $_[0], $ROUND);
    $r;
}

#
## MPFR
#

sub _mpfr2mpc {
    my $r = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_fr($r, $_[0], $ROUND);
    $r;
}

#
## Any
#

sub _any2mpc {
    my ($x) = @_;

    my $ref = ref($x);

    $ref eq 'Math::MPC'  && return $x;
    $ref eq 'Math::GMPq' && goto &_mpq2mpc;
    $ref eq 'Math::GMPz' && goto &_mpz2mpc;

    goto &_mpfr2mpc;
}

sub _any2mpfr {
    my ($x) = @_;
    my $ref = ref($x);

    $ref eq 'Math::MPFR' && return $x;
    $ref eq 'Math::GMPq' && goto &_mpq2mpfr;
    $ref eq 'Math::GMPz' && goto &_mpz2mpfr;

    my $fr = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::RMPC_IM($fr, $x);

    if (Math::MPFR::Rmpfr_equal_p($fr, $ZERO_F)) {
        Math::MPC::RMPC_RE($fr, $x);
    }
    else {
        Math::MPFR::Rmpfr_set_nan($fr);
    }

    $fr;
}

sub _any2mpz {
    my ($x) = @_;
    my $ref = ref($x);

    $ref eq 'Math::GMPz' && return $x;
    $ref eq 'Math::GMPq' && goto &_mpq2mpz;

    if ($ref eq 'Math::MPFR') {
        if (Math::MPFR::Rmpfr_number_p($x)) {
            my $z = Math::GMPz::Rmpz_init();
            Math::MPFR::Rmpfr_get_z($z, $x, $ROUND);
            return $z;
        }
        return;
    }

    (@_) = _any2mpfr($x);
    goto &_any2mpz;
}

sub _any2mpq {
    my ($x) = @_;
    my $ref = ref($x);

    $ref eq 'Math::GMPq' && return $x;
    $ref eq 'Math::GMPz' && goto &_mpz2mpq;

    if ($ref eq 'Math::MPFR') {
        if (Math::MPFR::Rmpfr_number_p($x)) {
            my $q = Math::GMPq::Rmpq_init();
            Math::MPFR::Rmpfr_get_q($q, $x);
            return $q;
        }
        return;
    }

    (@_) = _any2mpfr($x);
    goto &_any2mpq;
}

sub _any2ui {
    my ($x) = @_;
    my $ref = ref($x);

    if ($ref eq 'Math::GMPz') {
        my $d = CORE::int(Math::GMPz::Rmpz_get_d($x));
        ($d < 0 or $d > ULONG_MAX) && return;
        return $d;
    }

    if ($ref eq 'Math::GMPq') {
        my $d = CORE::int(Math::GMPq::Rmpq_get_d($x));
        ($d < 0 or $d > ULONG_MAX) && return;
        return $d;
    }

    if ($ref eq 'Math::MPFR') {
        my $d = CORE::int(Math::MPFR::Rmpfr_get_d($x, $ROUND));
        ($d < 0 or $d > ULONG_MAX) && return;
        return $d;
    }

    (@_) = _any2mpfr($x);
    goto &_any2ui;
}

sub _any2si {
    my ($x) = @_;
    my $ref = ref($x);

    if ($ref eq 'Math::GMPz') {
        my $d = CORE::int(Math::GMPz::Rmpz_get_d($x));
        ($d < LONG_MIN or $d > ULONG_MAX) && return;
        return $d;
    }

    if ($ref eq 'Math::GMPq') {
        my $d = CORE::int(Math::GMPq::Rmpq_get_d($x));
        ($d < LONG_MIN or $d > ULONG_MAX) && return;
        return $d;
    }

    if ($ref eq 'Math::MPFR') {
        my $d = CORE::int(Math::MPFR::Rmpfr_get_d($x, $ROUND));
        ($d < LONG_MIN or $d > ULONG_MAX) && return;
        return $d;
    }

    (@_) = _any2mpfr($x);
    goto &_any2si;
}

#~ # Converts an mpfr object to AnyNum
#~ sub _mpfr2big {

#~ if (!Math::MPFR::Rmpfr_number_p($_[0])) {

#~ if (Math::MPFR::Rmpfr_inf_p($_[0])) {
#~ if (Math::MPFR::Rmpfr_sgn($_[0]) > 0) {
#~ return inf();
#~ }
#~ else {
#~ return ninf();
#~ }
#~ }

#~ if (Math::MPFR::Rmpfr_nan_p($_[0])) {
#~ return nan();
#~ }
#~ }

#~ my $r = Math::GMPq::Rmpq_init();
#~ Math::MPFR::Rmpfr_get_q($r, $_[0]);
#~ bless \$r, __PACKAGE__;
#~ }

#~ # Converts an mpfr object to mpq and puts it in $x
#~ sub _mpfr2x {

#~ if (!Math::MPFR::Rmpfr_number_p($_[1])) {

#~ if (Math::MPFR::Rmpfr_inf_p($_[1])) {
#~ if (Math::MPFR::Rmpfr_sgn($_[1]) > 0) {
#~ return $_[0]->binf;
#~ }
#~ else {
#~ return $_[0]->bninf;
#~ }
#~ }

#~ if (Math::MPFR::Rmpfr_nan_p($_[1])) {
#~ return $_[0]->bnan;
#~ }
#~ }

#~ Math::MPFR::Rmpfr_get_q(${$_[0]}, $_[1]);
#~ $_[0];
#~ }

#~ # Converts an mpz object to AnyNum
#~ sub _mpz2big {
#~ my $r = Math::GMPq::Rmpq_init();
#~ Math::GMPq::Rmpq_set_z($r, $_[0]);
#~ bless \$r, __PACKAGE__;
#~ }

sub new {
    my ($class, $num, $base) = @_;

    my $ref = ref($num);

    # Be forgetful about undefined values or empty strings
    if ($ref eq '' and !$num) {
        goto &zero;
    }

    # Special string values
    elsif (!defined($base) and $ref eq '') {
        my $lc = lc($num);
        if ($lc eq 'inf' or $lc eq '+inf') {
            goto &inf;
        }
        elsif ($lc eq '-inf') {
            goto &ninf;
        }
        elsif ($lc eq 'nan') {
            goto &nan;
        }
    }

    # Special objects
    elsif ($ref eq 'Math::AnyNum') {
        return $num->copy;
    }

    # Special values as Big{Int,Float,Rat}
    elsif (   $ref eq 'Math::BigInt'
           or $ref eq 'Math::BigFloat'
           or $ref eq 'Math::BigRat') {
        if ($num->is_nan) {
            goto &nan;
        }
        elsif ($num->is_inf('-')) {
            goto &ninf;
        }
        elsif ($num->is_inf('+')) {
            goto &inf;
        }
    }

    # GMPz
    elsif ($ref eq 'Math::GMPz') {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set($r, $num);
        return bless \$r, $class;
    }

    # BigNum
    elsif ($ref eq 'Math::BigNum') {
        my $r = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set($r, $$num);
        return bless \$r, $class;
    }

    # MPFR
    elsif ($ref eq 'Math::MPFR') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set($r, $num, $ROUND);
        return bless \$r, $class;
    }
    elsif ($ref eq 'Math::MPC') {
        my $r = Math::MPC::Rmpc_init2($PREC);
        Math::MPC::Rmpc_set($r, $num, $ROUND);
        return bless \$r, $class;
    }

    # Plain scalar
    if ($ref eq '' and (!defined($base) or CORE::int($base) == 10)) {    # it's a base 10 scalar
        return bless \(_str2obj($num)), $class;                          # so we can return faster
    }

    # BigInt
    if ($ref eq 'Math::BigInt') {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set_str($r, $num->bstr, 10);
        return bless \$r, __PACKAGE__;
    }

    # BigFloat
    elsif ($ref eq 'Math::BigFloat') {
        return bless \(_str2obj($num->bstr)), $class;
    }

    # BigRat
    elsif ($ref eq 'Math::BigRat') {
        my $r = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set_str($r, $num->bstr, 10);
        return bless \$r, $class;
    }

    # GMPq
    elsif ($ref eq 'Math::GMPq') {
        my $r = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set($r, $num);
        return bless \$r, $class;
    }

    # Number with base
    elsif (defined($base) and $ref eq '') {

        my $int_base = CORE::int($base);

        if ($int_base < 2 or $int_base > 36) {
            require Carp;
            Carp::croak("base must be between 2 and 36, got $base");
        }

        if (index($num, '/') != -1) {
            my $r = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_str($r, $num, $int_base);
            Math::GMPq::Rmpq_canonicalize($r);
            return bless \$r, $class;
        }
        elsif (index($num, '.') != -1) {
            my $r = Math::MPFR::Rmpfr_init2($PREC);
            if (Math::MPFR::Rmpfr_set_str($r, $num, $int_base, $ROUND)) {
                Math::MPFR::Rmpfr_set_nan($r);
            }
            return bless \$r, $class;
        }
        else {
            my $r = Math::GMPz::Rmpz_init();
            Math::GMPq::Rmpz_set_str($r, $num, $int_base);
            return bless \$r, $class;
        }
    }

    bless \(_str2obj("$num")), $class;
}

=head2 new_si

    Math::AnyNum->new_si(Scalar)        # => AnyNum

A faster version of the method C<new()> for setting a I<signed> native integer.

Example:

    my $x = Math::AnyNum->new_si(-42);

=cut

sub new_si {
    my (undef, $si) = @_;
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_si($r, $si);
    bless \$r, __PACKAGE__;
}

=head2 new_ui

    Math::AnyNum->new_ui(Scalar)       # => AnyNum

A faster version of the method C<new()> for setting an I<unsigned> native integer.

Example:

    my $x = Math::AnyNum->new_ui(42);

=cut

sub new_ui {
    my (undef, $ui) = @_;
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_ui($r, $ui);
    bless \$r, __PACKAGE__;
}

sub new_z {
    my (undef, $str, $base) = @_;
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_str($r, $str, $base // 10);
    bless \$r, __PACKAGE__;
}

sub new_q {
    my (undef, $str, $base) = @_;
    my $r = Math::GMPq::Rmpq_init();
    Math::GMPq::Rmpq_set_str($r, $str, $base // 10);
    Math::GMPq::Rmpq_canonicalize($r) if index($str, '/') != -1;
    bless \$r, __PACKAGE__;
}

sub new_f {
    my (undef, $str, $base) = @_;
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_str($r, $str, $base // 10, $ROUND);
    bless \$r, __PACKAGE__;
}

sub new_c {
    my (undef, $real, $imag, $base) = @_;

    my $c = Math::MPC::Rmpc_init2($PREC);

    if (defined($imag)) {
        my $re = Math::MPFR::Rmpfr_init2($PREC);
        my $im = Math::MPFR::Rmpfr_init2($PREC);

        Math::MPFR::Rmpfr_set_str($re, $real, $base // 10, $ROUND);
        Math::MPFR::Rmpfr_set_str($im, $imag, $base // 10, $ROUND);

        Math::MPC::Rmpc_set_fr_fr($c, $re, $im, $ROUND);
    }
    else {
        Math::MPC::Rmpc_set_str($c, $real, $base // 10, $ROUND);
    }

    bless \$c, __PACKAGE__;
}

sub _nan {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_nan($r);
    $r;
}

sub nan {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_nan($r);
    bless \$r, __PACKAGE__;
}

sub _inf {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_inf($r, 1);
    $r;
}

sub inf {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_inf($r, 1);
    bless \$r, __PACKAGE__;
}

sub _ninf {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_inf($r, -1);
    $r;
}

sub ninf {
    my $r = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_set_inf($r, -1);
    bless \$r, __PACKAGE__;
}

sub zero {
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_ui($r, 0);
    bless \$r, __PACKAGE__;
}

sub one {
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_ui($r, 1);
    bless \$r, __PACKAGE__;
}

sub mone {
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_si($r, -1);
    bless \$r, __PACKAGE__;
}

#
## CONSTANTS
#

=head2 pi

    Math::AnyNum->pi               # => BigNum

Returns the number PI, which is C<3.1415...>.

=cut

sub pi {
    my $pi = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($pi, $ROUND);
    bless \$pi, __PACKAGE__;
}

=head2 tau

    Math::AnyNum->tau              # => BigNum

Returns the number TAU, which is C<2*PI>.

=cut

sub tau {
    my $tau = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($tau, $ROUND);
    Math::MPFR::Rmpfr_mul_ui($tau, $tau, 2, $ROUND);
    bless \$tau, __PACKAGE__;
}

=head2 ln2

    Math::AnyNum->ln2              # => BigNum

Returns the natural logarithm of C<2>.

=cut

sub ln2 {
    my $ln2 = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_log2($ln2, $ROUND);
    bless \$ln2, __PACKAGE__;
}

=head2 euler

    Math::AnyNum->euler                # => BigNum

Returns the Euler-Mascheroni constant, which is C<0.57721...>.

=cut

sub euler {
    my $euler = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_euler($euler, $ROUND);
    bless \$euler, __PACKAGE__;
}

=head2 catalan

    Math::AnyNum->catalan                # => BigNum

Returns the value of Catalan's constant, also known
as Beta(2) or G, and starts as: C<0.91596...>.

=cut

sub catalan {
    my $catalan = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_catalan($catalan, $ROUND);
    bless \$catalan, __PACKAGE__;
}

=head2 i

    Math::AnyNum->i                # => Complex

Returns the imaginary unit, which is C<sqrt(-1)>.

=cut

sub i {
    my $i = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_ui_ui($i, 0, 1, $ROUND);
    bless \$i, __PACKAGE__;
}

=head2 e

    Math::AnyNum->e                # => BigNum

Returns the e mathematical constant, which is C<2.718...>.

=cut

sub e {
    state $one_f = (Math::MPFR::Rmpfr_init_set_ui_nobless(1, $ROUND))[0];
    my $e = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_exp($e, $one_f, $ROUND);
    bless \$e, __PACKAGE__;
}

=head2 phi

    Math::AnyNum->phi              # => BigNum

Returns the value of the golden ratio, which is C<1.61803...>.

=cut

sub phi {
    state $five4_f = (Math::MPFR::Rmpfr_init_set_str_nobless("1.25", 10, $ROUND))[0];
    state $half_f  = (Math::MPFR::Rmpfr_init_set_str_nobless("0.5",  10, $ROUND))[0];

    my $phi = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_sqrt($phi, $five4_f, $ROUND);
    Math::MPFR::Rmpfr_add($phi, $phi, $half_f, $ROUND);

    bless \$phi, __PACKAGE__;
}

#
## OTHER
#

sub stringify {
    require Math::AnyNum::stringify;
    (@_) = (${$_[0]});
    goto &__stringify__;
}

sub numify {
    require Math::AnyNum::numify;
    (@_) = (${$_[0]});
    goto &__numify__;
}

sub boolify {
    require Math::AnyNum::boolify;
    (@_) = (${$_[0]});
    goto &__boolify__;
}

#
## EQ
#

Class::Multimethods::multimethod eq => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::eq;
    my ($x, $y) = @_;
    (@_) = ($$x, $$y);
    goto &__eq__;
};

Class::Multimethods::multimethod eq => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::eq;
    my ($x, $y) = @_;
    (@_) = ($$x, ${__PACKAGE__->new($y)});
    goto &__eq__;
};

#
## NE
#

Class::Multimethods::multimethod ne => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::ne;
    my ($x, $y) = @_;
    (@_) = ($$x, $$y);
    goto &__ne__;
};

Class::Multimethods::multimethod ne => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::ne;
    my ($x, $y) = @_;
    (@_) = ($$x, ${__PACKAGE__->new($y)});
    goto &__ne__;
};

#
## CMP
#

Class::Multimethods::multimethod cmp => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (@_) = ($$x, $$y);
    goto &__cmp__;
};

Class::Multimethods::multimethod cmp => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (@_) = ($$x, ${__PACKAGE__->new($y)});
    goto &__cmp__;
};

#
## GT
#

Class::Multimethods::multimethod gt => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, $$y) > 0;
};

Class::Multimethods::multimethod gt => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, ${__PACKAGE__->new($y)}) > 0;
};

#
## GE
#

Class::Multimethods::multimethod ge => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, $$y) >= 0;
};

Class::Multimethods::multimethod ge => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, ${__PACKAGE__->new($y)}) >= 0;
};

#
## LT
#
Class::Multimethods::multimethod lt => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, $$y) < 0;
};

Class::Multimethods::multimethod lt => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, ${__PACKAGE__->new($y)}) < 0;
};

#
## LE
#
Class::Multimethods::multimethod le => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, $$y) <= 0;
};

Class::Multimethods::multimethod le => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    __cmp__($$x, ${__PACKAGE__->new($y)}) <= 0;
};

sub copy {
    require Math::AnyNum::copy;
    my ($x) = @_;
    my $r = __copy__($$x);
    bless \$r, __PACKAGE__;
}

sub int {
    my ($x) = @_;
    $$x = _any2mpz($$x) // (goto &to_nan);
    $x;
}

sub rat {
    my ($x) = @_;
    $$x = _any2mpq($$x) // (goto &to_nan);
    $x;
}

sub float {
    my ($x) = @_;
    $$x = _any2mpfr($$x);
    $x;
}

sub complex {
    my ($x) = @_;
    $$x = _any2mpc($$x);
    $x;
}

sub neg {
    require Math::AnyNum::neg;
    my ($x) = @_;
    $$x = __neg__($$x);
    $x;
}

sub abs {
    require Math::AnyNum::abs;
    my ($x) = @_;
    $$x = __abs__($$x);
    $x;
}

sub inv {
    require Math::AnyNum::inv;
    my ($x) = @_;
    $$x = __inv__($$x);
    $x;
}

sub real {
    require Math::AnyNum::real;
    my ($x) = @_;
    $$x = __real__($$x);
    $x;
}

sub imag {
    require Math::AnyNum::imag;
    my ($x) = @_;
    $$x = __imag__($$x);
    $x;
}

#
## ADD
#

Class::Multimethods::multimethod add => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::add;
    my ($x, $y) = @_;
    $$x = __add__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod add => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::add;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        if (ref($$x) eq 'Math::GMPq') {
            my $r = Math::GMPq::Rmpq_init();
            $y < 0
              ? Math::GMPq::Rmpq_set_si($r, $y, 1)
              : Math::GMPq::Rmpq_set_ui($r, $y, 1);
            Math::GMPq::Rmpq_add($$x, $$x, $r);
        }
        else {
            $$x = __add__($$x, $y);
        }
    }
    else {
        $$x = __add__($$x, _str2obj($y));
    }

    $x;
};

Class::Multimethods::multimethod add => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::add;
    my ($x, $y) = @_;
    $$x = __add__($$x, ${__PACKAGE__->new($y)});
    $x;
};

Class::Multimethods::multimethod sub => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::sub;
    my ($x, $y) = @_;
    $$x = __sub__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod sub => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::sub;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        if (ref($$x) eq 'Math::GMPq') {
            my $r = Math::GMPq::Rmpq_init();
            $y < 0
              ? Math::GMPq::Rmpq_set_si($r, $y, 1)
              : Math::GMPq::Rmpq_set_ui($r, $y, 1);
            Math::GMPq::Rmpq_sub($$x, $$x, $r);
        }
        else {
            $$x = __sub__($$x, $y);
        }
    }
    else {
        $$x = __sub__($$x, _str2obj($y));
    }

    $x;
};

Class::Multimethods::multimethod sub => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::sub;
    my ($x, $y) = @_;
    $$x = __sub__($$x, ${__PACKAGE__->new($y)});
    $x;
};

#
## MULTIPLY
#

Class::Multimethods::multimethod mul => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::mul;
    my ($x, $y) = @_;
    $$x = __mul__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod mul => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::mul;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        if (ref($$x) eq 'Math::GMPq') {
            my $r = Math::GMPq::Rmpq_init();
            $y < 0
              ? Math::GMPq::Rmpq_set_si($r, $y, 1)
              : Math::GMPq::Rmpq_set_ui($r, $y, 1);
            Math::GMPq::Rmpq_mul($$x, $$x, $r);
        }
        else {
            $$x = __mul__($$x, $y);
        }
    }
    else {
        $$x = __mul__($$x, _str2obj($y));
    }

    $x;
};

Class::Multimethods::multimethod mul => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::mul;
    my ($x, $y) = @_;
    $$x = __mul__($$x, ${__PACKAGE__->new($y)});
    $x;
};

#
## DIVISION
#

Class::Multimethods::multimethod div => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = __div__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod div => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN and CORE::int($y) != 0) {
        if (ref($$x) eq 'Math::GMPq') {
            my $r = Math::GMPq::Rmpq_init();
            $y < 0
              ? Math::GMPq::Rmpq_set_si($r, $y, 1)
              : Math::GMPq::Rmpq_set_ui($r, $y, 1);
            Math::GMPq::Rmpq_div($$x, $$x, $r);
        }
        elsif (ref($$x) eq 'Math::GMPz') {
            my $r = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_ui($r, 1, CORE::abs($y));
            Math::GMPq::Rmpq_set_num($r, $$x);
            Math::GMPq::Rmpq_neg($r, $r) if $y < 0;
            Math::GMPq::Rmpq_canonicalize($r);
            $$x = $r;
        }
        else {
            $$x = __div__($$x, $y);
        }
    }
    else {
        $$x = __div__($$x, _str2obj($y));
    }

    $x;
};

Class::Multimethods::multimethod div => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = __div__($$x, ${__PACKAGE__->new($y)});
    $x;
};

#
## POWER
#

Class::Multimethods::multimethod pow => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    $$x = __pow__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod pow => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        $$x = __pow__($$x, $y);
    }
    else {
        $$x = __pow__($$x, _str2obj($y));
    }

    $x;
};

Class::Multimethods::multimethod pow => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    $$x = __pow__($$x, ${__PACKAGE__->new($y)});
    $x;
};

#
## ROOT
#

Class::Multimethods::multimethod root => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    $$x = __pow__($$x, __inv__(${$y->copy}));
    $x;
};

Class::Multimethods::multimethod root => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    $$x = __pow__($$x, __inv__(_str2obj($y)));
    $x;
};

Class::Multimethods::multimethod root => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    $$x = __pow__($$x, __inv__(${__PACKAGE__->new($y)}));
    $x;
};

sub to_nan {
    my ($x) = @_;
    if (ref($$x) eq 'Math::MPFR') {
        Math::MPFR::Rmpfr_set_nan($$x);
    }
    else {
        $$x = _nan();
    }
    $x;
}

#
## IROOT
#
Class::Multimethods::multimethod iroot => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    $$x = __iroot__(_any2mpz($$x) // (goto &to_nan), _any2si($$y) // (goto &to_nan));
    $x;
};

Class::Multimethods::multimethod iroot => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y >= 0 and $y <= ULONG_MAX) {
        $$x = __iroot__(_any2mpz($$x) // (goto &to_nan), $y);
    }
    else {
        $$x = __iroot__(_any2mpz($$x) // (goto &to_nan), _any2si(_str2obj($y)) // (goto &to_nan));
    }
    $x;
};

Class::Multimethods::multimethod iroot => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    $$x = __iroot__(_any2mpz($$x) // (goto &to_nan), _any2si(${__PACKAGE__->new($y)}) // (goto &to_nan));
    $x;
};

#
## SPECIAL
#

sub log2 {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = __log2__($$x);
    $x;
}

sub log10 {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = __log10__($$x);
    $x;
}

Class::Multimethods::multimethod log => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = __div__(__log__($$x), __log__(${$y->copy}));
    $x;
};

Class::Multimethods::multimethod log => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;

    if ($y == 2) {
        goto &log2;
    }
    elsif ($y == 10) {
        goto &log10;
    }

    $$x = __div__(__log__($$x), __log__(_str2obj($y)));
    $x;
};

Class::Multimethods::multimethod log => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = __div__(__log__($$x), __log__(${__PACKAGE__->new($y)}));
    $x;
};

Class::Multimethods::multimethod log => qw(Math::AnyNum) => sub {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = __log__($$x);
    $x;
};

sub sqrt {
    require Math::AnyNum::sqrt;
    my ($x) = @_;
    $$x = __sqrt__($$x);
    $x;
}

sub exp {
    require Math::AnyNum::exp;
    my ($x) = @_;
    $$x = __exp__($$x);
    $x;
}

sub zeta {
    require Math::AnyNum::zeta;
    my ($x) = @_;
    $$x = __zeta__(_any2mpfr($$x));
    $x;
}

sub lambert_w {
    require Math::AnyNum::lambert_w;
    my ($x) = @_;
    $$x = __lambert_w__(ref($$x) eq 'Math::MPC' ? $$x : _any2mpfr($$x));
    $x;
}

sub lgrt {
    require Math::AnyNum::lgrt;
    my ($x) = @_;
    $$x = __lgrt__(ref($$x) eq 'Math::MPC' ? $$x : _any2mpfr($$x));
    $x;
}

#
## ROUND
#

Class::Multimethods::multimethod round => qw(Math::AnyNum) => sub {
    require Math::AnyNum::round;
    my ($x) = @_;
    $$x = __round__($$x, 0);
    $x;
};

Class::Multimethods::multimethod round => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;
    $$x = __round__($$x, _any2si($$y) // (goto &to_nan));
    $x;
};

Class::Multimethods::multimethod round => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        $$x = __round__($$x, $y);
    }
    else {
        $$x = __round__($$x, _any2si(_str2obj($y)) // (goto &to_nan));
    }
    $x;
};

Class::Multimethods::multimethod round => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;
    $$x = __round__($$x, _any2si(${__PACKAGE__->new($y)}) // (goto &to_nan));
    $x;
};

#
## Factorial
#
sub factorial {
    my ($x) = @_;

    if (ref($x) eq '') {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_fac_ui($z, $x);
            return bless \$z, __PACKAGE__;
        }

        return __PACKAGE__->new($x)->factorial;
    }

    my $ui = _any2ui($$x) // (goto &to_nan);
    my $z = ref($$x) eq 'Math::GMPz' ? $$x : Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_fac_ui($z, $ui);
    $$x = $z;
    $x;
}

#
## Binomial
#

Class::Multimethods::multimethod binomial => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;
    my $n = _any2si($$y)  // (goto &to_nan);
    my $z = _any2mpz($$x) // (goto &to_nan);

    $n < 0
      ? Math::GMPz::Rmpz_bin_si($z, $z, $n)
      : Math::GMPz::Rmpz_bin_ui($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod binomial => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _any2mpz($$x) // (goto &to_nan);

        $y < 0
          ? Math::GMPz::Rmpz_bin_si($z, $z, $y)
          : Math::GMPz::Rmpz_bin_ui($z, $z, $y);

        $$x = $z;
        $x;
    }
    else {
        (@_) = ($x, __PACKAGE__->new($y));
        goto &binomial;
    }
};

Class::Multimethods::multimethod binomial => qw($ $) => sub {
    my ($x, $y) = @_;

    if (    CORE::int($x) eq $x
        and CORE::int($y) eq $y
        and $x >= 0
        and $y >= 0
        and $x <= ULONG_MAX
        and $y <= ULONG_MAX) {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_bin_uiui($z, $x, $y);
        return bless \$z, __PACKAGE__;
    }

    (@_) = (__PACKAGE__->new($x), $y);
    goto &binomial;
};

Class::Multimethods::multimethod binomial => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &binomial;
};

Class::Multimethods::multimethod binomial => qw($ *) => sub {
    my ($x, $y) = @_;
    (@_) = (__PACKAGE__->new($x), __PACKAGE__->new($y));
    goto &binomial;
};

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Daniel Șuteu.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Math::AnyNum
