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
    $PREC  = 192;
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
  '|='  => sub { $_[0]->or($_[1]) },
  '<<=' => sub { $_[0]->lsft($_[1]) },
  '>>=' => sub { $_[0]->rsft($_[1]) },

  '+' => sub { $_[0]->copy->add($_[1]) },
  '*' => sub { $_[0]->copy->mul($_[1]) },

  '==' => sub { $_[0]->eq($_[1]) },
  '!=' => sub { $_[0]->ne($_[1]) },

  '&' => sub { $_[0]->copy->and($_[1]) },
  '|' => sub { $_[0]->copy->or($_[1]) },
  '^' => sub { $_[0]->copy->xor($_[1]) },
  '~' => sub { $_[0]->copy->not },

  '++' => \&inc,
  '--' => \&dec,

#<<<
  '>'   => sub { $_[2] ?  Math::AnyNum::lt ($_[0], $_[1]) : Math::AnyNum::gt ($_[0], $_[1]) },
  '>='  => sub { $_[2] ?  Math::AnyNum::le ($_[0], $_[1]) : Math::AnyNum::ge ($_[0], $_[1]) },
  '<'   => sub { $_[2] ?  Math::AnyNum::gt ($_[0], $_[1]) : Math::AnyNum::lt ($_[0], $_[1]) },
  '<='  => sub { $_[2] ?  Math::AnyNum::ge ($_[0], $_[1]) : Math::AnyNum::le ($_[0], $_[1]) },
  '<=>' => sub { $_[2] ? -Math::AnyNum::cmp($_[0], $_[1]) : Math::AnyNum::cmp($_[0], $_[1]) },
#>>>

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

    my %functions = (
                     factorial => \&factorial,
                     binomial  => \&binomial,
                     fibonacci => \&fibonacci,
                     lucas     => \&lucas,
                     primorial => \&primorial,
                     rand      => \&rand,
                     irand     => \&irand,
                     invmod    => \&invmod,
                     powmod    => \&powmod,
                     gcd       => \&gcd,
                     bernfrac  => \&bernfrac,
                     bernreal  => \&bernreal,
                    );

    sub import {
        shift;

        my $caller = caller(0);

        while (@_) {
            my $name = shift(@_);

            if ($name eq ':constant') {
                overload::constant
                  integer => sub { __PACKAGE__->new_ui($_[0]) },
                  float   => sub { __PACKAGE__->new_f($_[0]) },
                  binary  => sub {
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
            elsif (exists $functions{$name}) {
                no strict 'refs';
                my $caller_sub = $caller . '::' . $name;
                if (!defined &$caller_sub) {
                    *$caller_sub = $functions{$name};
                }
            }
            elsif ($name eq ':all') {
                push @_, keys(%constants), keys(%functions);
            }
            elsif ($name eq 'PREC') {
                my $prec = CORE::int(shift(@_));
                if (   $prec < Math::MPFR::RMPFR_PREC_MIN()
                    or $prec > Math::MPFR::RMPFR_PREC_MAX()) {
                    die "invalid value for <<PREC>>: must be between "
                      . Math::MPFR::RMPFR_PREC_MIN() . " and "
                      . Math::MPFR::RMPFR_PREC_MAX();
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

    # Complex number
    if (substr($s, -1) eq 'i') {

        if ($s eq 'i' or $s eq '+i') {
            my $r = Math::MPC::Rmpc_init2($PREC);
            Math::MPC::Rmpc_set_ui_ui($r, 0, 1, $ROUND);
            return $r;
        }
        elsif ($s eq '-i') {
            my $r = Math::MPC::Rmpc_init2($PREC);
            Math::MPC::Rmpc_set_si_si($r, 0, -1, $ROUND);
            return $r;
        }

        my ($re, $im);

        state $numeric_re  = qr/[+-]?+(?=\.?[0-9])[0-9]*+(?:\.[0-9]++)?(?:[Ee](?:[+-]?+[0-9]+))?/;
        state $unsigned_re = qr/(?=\.?[0-9])[0-9]*+(?:\.[0-9]++)?(?:[Ee](?:[+-]?+[0-9]+))?/;

        if ($s =~ /^($numeric_re)\s*([-+])\s*($unsigned_re)i\z/o) {
            ($re, $im) = ($1, $3);
            $im = "-$im" if $2 eq '-';
        }
        elsif ($s =~ /^($numeric_re)i\z/o) {
            ($re, $im) = (0, $1);
        }
        elsif ($s =~ /^($numeric_re)\s*([-+])\s*i\z/o) {
            ($re, $im) = ($1, 1);
            $im = -1 if $2 eq '-';
        }

        if (defined($re) and defined($im)) {

            my $r = Math::MPC::Rmpc_init2($PREC);

            if ($im eq '+') {
                $im = 1;
            }
            elsif ($im eq '-') {
                $im = -1;
            }

            $re = _str2obj($re);
            $im = _str2obj($im);

            my $re_type = ref($re);
            my $im_type = ref($im);

            if ($re_type eq 'Math::MPFR' and $im_type eq 'Math::MPFR') {
                Math::MPC::Rmpc_set_fr_fr($r, $re, $im, $ROUND);
            }
            elsif ($re_type eq 'Math::GMPz' and $im_type eq 'Math::GMPz') {
                Math::MPC::Rmpc_set_z_z($r, $re, $im, $ROUND);
            }
            elsif ($re_type eq 'Math::GMPz' and $im_type eq 'Math::MPFR') {
                Math::MPC::Rmpc_set_z_fr($r, $re, $im, $ROUND);
            }
            elsif ($re_type eq 'Math::MPFR' and $im_type eq 'Math::GMPz') {
                Math::MPC::Rmpc_set_fr_z($r, $re, $im, $ROUND);
            }
            else {    # this should never happen
                $re = _any2mpfr($re);
                $im = _any2mpfr($im);
                Math::MPC::Rmpc_set_fr_fr($r, $re, $im, $ROUND);
            }

            return $r;
        }
    }

    # Floating point value
    if ($s =~ tr/e.//) {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        if (Math::MPFR::Rmpfr_set_str($r, $s, 10, $ROUND)) {
            Math::MPFR::Rmpfr_set_nan($r);
        }
        return $r;
    }

    # Fractional value
    if (index($s, '/') != -1 and $s =~ m{^\s*[-+]?[0-9]+\s*/\s*[-+]?[1-9]+[0-9]*\s*\z}) {
        my $r = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set_str($r, $s, 10);
        Math::GMPq::Rmpq_canonicalize($r);
        return $r;
    }

    #~ # Floating-point exponential
    #~ if (index($s, 'e') != -1) {
    #~ my $r = Math::MPFR::Rmpfr_init2($PREC);
    #~ if (Math::MPFR::Rmpfr_set_str($r, $s, 10, $ROUND)) {
    #~ Math::MPFR::Rmpfr_set_nan($r);
    #~ }
    #~ return $r;
    #~ }

    #~ if (index($s, '.') != -1) {
    #~ my $rat = _str2rat($s);

    #~ # Not a valid number
    #~ if ($rat !~ m{^\s*[-+]?[0-9]+(?>\s*/\s*[-+]?[1-9]+[0-9]*)?\s*\z}) {
    #~ my $r = Math::MPFR::Rmpfr_init2($PREC);
    #~ if (Math::MPFR::Rmpfr_set_str($r, $s, 10, $ROUND)) {
    #~ Math::MPFR::Rmpfr_set_nan($r);
    #~ }
    #~ return $r;
    #~ }

    #~ # Rational number (a/b)
    #~ if (index($rat, '/') != -1) {
    #~ my $r = Math::GMPq::Rmpq_init();
    #~ Math::GMPq::Rmpq_set_str($r, $rat, 10);
    #~ Math::GMPq::Rmpq_canonicalize($r);
    #~ return $r;
    #~ }

    #~ # For values like 42.000
    #~ my $r = Math::GMPz::Rmpz_init();
    #~ Math::GMPz::Rmpz_set_str($r, $rat, 10);
    #~ return $r;
    #~ }

    $s =~ s/^\+//;

    my $r = Math::GMPz::Rmpz_init();
    eval { Math::GMPz::Rmpz_set_str($r, $s, 10); 1 } // do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        return $r;
    };
    return $r;
}

# Converts a string into an mpz object
#~ sub _str2mpz {
#~ (CORE::int($_[0]) eq $_[0] and $_[0] <= ULONG_MAX and $_[0] >= LONG_MIN)
#~ ? (
#~ ($_[0] >= 0)
#~ ? Math::GMPz::Rmpz_init_set_ui($_[0])
#~ : Math::GMPz::Rmpz_init_set_si($_[0])
#~ )
#~ : eval { Math::GMPz::Rmpz_init_set_str($_[0], 10) };
#~ }

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
            Math::MPFR::Rmpfr_get_z($z, $x, Math::MPFR::MPFR_RNDZ);
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
            eval {
                Math::GMPq::Rmpq_set_str($r, $num, $int_base);
                1;
              } // do {
                my $r = Math::MPFR::Rmpfr_init2($PREC);
                Math::MPFR::Rmpfr_set_nan($r);
                return bless \$r, $class;
              };
            if (Math::GMPq::Rmpq_get_str($r, 10) !~ m{^\s*[-+]?[0-9]+\s*/\s*[-+]?[1-9]+[0-9]*\s*\z}) {
                my $r = Math::MPFR::Rmpfr_init2($PREC);
                Math::MPFR::Rmpfr_set_nan($r);
                return bless \$r, $class;
            }
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
            eval { Math::GMPz::Rmpz_set_str($r, $num, $int_base); 1 } // do {
                my $r = Math::MPFR::Rmpfr_init2($PREC);
                Math::MPFR::Rmpfr_set_nan($r);
                return bless \$r, $class;
            };
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
    my (undef, $num, $den, $base) = @_;
    my $r = Math::GMPq::Rmpq_init();

    if (defined($den)) {
        Math::GMPq::Rmpq_set_str($r, "$num/$den", $base // 10);
    }
    else {
        Math::GMPq::Rmpq_set_str($r, "$num", $base // 10);
    }

    Math::GMPq::Rmpq_canonicalize($r);
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

sub to_inf {
    my ($x) = @_;
    if (ref($$x) eq 'Math::MPFR') {
        Math::MPFR::Rmpfr_set_inf($$x, 1);
    }
    else {
        $$x = _inf();
    }
    $x;
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

sub to_ninf {
    my ($x) = @_;
    if (ref($$x) eq 'Math::MPFR') {
        Math::MPFR::Rmpfr_set_inf($$x, -1);
    }
    else {
        $$x = _ninf();
    }
    $x;
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

    Math::AnyNum->pi               # => MPFR

Returns the number PI, which is C<3.1415...>.

=cut

sub pi {
    my $pi = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($pi, $ROUND);
    bless \$pi, __PACKAGE__;
}

=head2 tau

    Math::AnyNum->tau              # => MPFR

Returns the number TAU, which is C<2*PI>.

=cut

sub tau {
    my $tau = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($tau, $ROUND);
    Math::MPFR::Rmpfr_mul_ui($tau, $tau, 2, $ROUND);
    bless \$tau, __PACKAGE__;
}

=head2 ln2

    Math::AnyNum->ln2              # => MPFR

Returns the natural logarithm of C<2>.

=cut

sub ln2 {
    my $ln2 = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_log2($ln2, $ROUND);
    bless \$ln2, __PACKAGE__;
}

=head2 euler

    Math::AnyNum->euler                # => MPFR

Returns the Euler-Mascheroni constant, which is C<0.57721...>.

=cut

sub euler {
    my $euler = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_euler($euler, $ROUND);
    bless \$euler, __PACKAGE__;
}

=head2 catalan

    Math::AnyNum->catalan                # => MPFR

Returns the value of Catalan's constant, also known
as Beta(2) or G, and starts as: C<0.91596...>.

=cut

sub catalan {
    my $catalan = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_catalan($catalan, $ROUND);
    bless \$catalan, __PACKAGE__;
}

=head2 i

    Math::AnyNum->i                # => MPC

Returns the imaginary unit, which is C<sqrt(-1)>.

=cut

sub i {
    my $i = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_ui_ui($i, 0, 1, $ROUND);
    bless \$i, __PACKAGE__;
}

=head2 e

    Math::AnyNum->e                # => MPFR

Returns the e mathematical constant, which is C<2.718...>.

=cut

sub e {
    state $one_f = (Math::MPFR::Rmpfr_init_set_ui_nobless(1, $ROUND))[0];
    my $e = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_exp($e, $one_f, $ROUND);
    bless \$e, __PACKAGE__;
}

=head2 phi

    Math::AnyNum->phi              # => MPFR

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

sub inc {
    require Math::AnyNum::inc;
    my ($x) = @_;
    $$x = __inc__($$x);
    $x;
}

sub dec {
    require Math::AnyNum::dec;
    my ($x) = @_;
    $$x = __dec__($$x);
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
## IDIV
#

Class::Multimethods::multimethod idiv => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2mpz($$x) // goto &to_nan;
    my $d = _any2mpz($$y) // goto &to_nan;

    # Detect division by zero
    if (!Math::GMPz::Rmpz_sgn($d)) {
        my $sign = Math::GMPz::Rmpz_sgn($n);

        if ($sign == 0) {    # 0/0
            goto &to_nan;
        }
        elsif ($sign > 0) {    # x/0 where: x > 0
            goto &to_inf;
        }
        else {                 # x/0 where: x < 0
            goto &to_ninf;
        }
    }

    Math::GMPz::Rmpz_tdiv_q($n, $n, $d);

    $$x = $n;
    $x;
};

Class::Multimethods::multimethod idiv => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) and CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        my $n = _any2mpz($$x) // goto &to_nan;
        Math::GMPz::Rmpz_tdiv_q_ui($n, $n, CORE::abs($y));
        Math::GMPz::Rmpz_neg($n, $n) if $y < 0;
        $$x = $n;
        $x;
    }
    else {
        (@_) = ($x, __PACKAGE__->new($y));
        goto &idiv;
    }
};

Class::Multimethods::multimethod idiv => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &idiv;
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
## INTEGER POWER
#

Class::Multimethods::multimethod ipow => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;
    $$x = __ipow__(_any2mpz($$x) // (goto &to_nan), _any2si($$y) // (goto &to_nan));
    $x;
};

Class::Multimethods::multimethod ipow => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        $$x = __ipow__(_any2mpz($$x) // (goto &to_nan), $y);
    }
    else {
        $$x = __ipow__(_any2mpz($$x) // (goto &to_nan), _any2si(_str2obj($y)) // (goto &to_nan));
    }
    $x;
};

Class::Multimethods::multimethod ipow => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &ipow;
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
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
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
## MOD
#

Class::Multimethods::multimethod mod => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;
    $$x = __mod__($$x, $$y);
    $x;
};

Class::Multimethods::multimethod mod => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;

    if (ref($$x) ne 'Math::GMPq' and CORE::int($y) eq $y and $y > 0 and $y <= ULONG_MAX) {
        $$x = __mod__($$x, $y);
    }
    else {
        $$x = __mod__($$x, _str2obj($y) // (goto &to_nan));
    }

    $x;
};

Class::Multimethods::multimethod mod => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;
    $$x = __mod__($$x, ${__PACKAGE__->new($y)});
    $x;
};

#
## IMOD
#

Class::Multimethods::multimethod imod => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::imod;
    my ($x, $y) = @_;

    my $z = _any2mpz($$x) // goto &to_nan;
    my $m = _any2mpz($$y) // goto &to_nan;

    $$x = __imod__($z, $m);
    $x;
};

Class::Multimethods::multimethod imod => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::imod;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        my $z = _any2mpz($$x) // goto &to_nan;
        $$x = __imod__($z, $y);
        $x;
    }
    else {
        (@_) = ($x, __PACKAGE__->new($y));
        goto &imod;
    }
};

Class::Multimethods::multimethod imod => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &imod;
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
    $$x = __div__(__log__(${$x->copy}), __log__(${$y->copy}));
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

    $$x = __div__(__log__(${$x->copy}), __log__(_str2obj($y)));
    $x;
};

Class::Multimethods::multimethod log => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = __div__(__log__(${$x->copy}), __log__(${__PACKAGE__->new($y)}));
    $x;
};

Class::Multimethods::multimethod log => qw(Math::AnyNum) => sub {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = __log__($$x);
    $x;
};

#
## ILOG
#

sub ilog2 {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = _any2mpz(__log2__($$x)) // _nan();
    $x;
}

sub ilog10 {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = _any2mpz(__log10__($$x)) // _nan();
    $x;
}

Class::Multimethods::multimethod ilog => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = _any2mpz(__div__(__log__(${$x->copy}), __log__(${$y->copy}))) // _nan();
    $x;
};

Class::Multimethods::multimethod ilog => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;

    if ($y == 2) {
        goto &ilog2;
    }
    elsif ($y == 10) {
        goto &ilog10;
    }

    $$x = _any2mpz(__div__(__log__(${$x->copy}), __log__(_str2obj($y)))) // _nan();
    $x;
};

Class::Multimethods::multimethod ilog => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    $$x = _any2mpz(__div__(__log__(${$x->copy}), __log__(${__PACKAGE__->new($y)}))) // _nan();
    $x;
};

Class::Multimethods::multimethod ilog => qw(Math::AnyNum) => sub {
    require Math::AnyNum::log;
    my ($x) = @_;
    $$x = _any2mpz(__log__($$x)) // _nan();
    $x;
};

#
## SQRT
#

sub sqrt {
    require Math::AnyNum::sqrt;
    my ($x) = @_;
    $$x = __sqrt__($$x);
    $x;
}

sub isqrt {
    my ($x) = @_;
    my $z = _any2mpz($$x) // goto &to_nan;
    Math::GMPz::Rmpz_sgn($z) < 0 && goto &to_nan;
    Math::GMPz::Rmpz_sqrt($z, $z);
    $$x = $z;
    $x;
}

sub exp {
    require Math::AnyNum::exp;
    my ($x) = @_;
    $$x = __exp__($$x);
    $x;
}

#
## sin / sinh / asin / asinh
#

sub sin {
    require Math::AnyNum::sin;
    my ($x) = @_;
    $$x = __sin__($$x);
    $x;
}

sub sinh {
    require Math::AnyNum::sinh;
    my ($x) = @_;
    $$x = __sinh__($$x);
    $x;
}

sub asin {
    require Math::AnyNum::asin;
    my ($x) = @_;
    $$x = __asin__($$x);
    $x;
}

sub asinh {
    require Math::AnyNum::asinh;
    my ($x) = @_;
    $$x = __asinh__($$x);
    $x;
}

#
## cos / cosh / acos / acosh
#

sub cos {
    require Math::AnyNum::cos;
    my ($x) = @_;
    $$x = __cos__($$x);
    $x;
}

sub cosh {
    require Math::AnyNum::cosh;
    my ($x) = @_;
    $$x = __cosh__($$x);
    $x;
}

sub acos {
    require Math::AnyNum::acos;
    my ($x) = @_;
    $$x = __acos__($$x);
    $x;
}

sub acosh {
    require Math::AnyNum::acosh;
    my ($x) = @_;
    $$x = __acosh__($$x);
    $x;
}

#
## tan / tanh / atan / atanh
#

sub tan {
    require Math::AnyNum::tan;
    my ($x) = @_;
    $$x = __tan__($$x);
    $x;
}

sub tanh {
    require Math::AnyNum::tanh;
    my ($x) = @_;
    $$x = __tanh__($$x);
    $x;
}

sub atan {
    require Math::AnyNum::atan;
    my ($x) = @_;
    $$x = __atan__($$x);
    $x;
}

sub atanh {
    require Math::AnyNum::atanh;
    my ($x) = @_;
    $$x = __atanh__($$x);
    $x;
}

#
## sec / sech / asec / asech
#

sub sec {
    require Math::AnyNum::sec;
    my ($x) = @_;
    $$x = __sec__($$x);
    $x;
}

sub sech {
    require Math::AnyNum::sech;
    my ($x) = @_;
    $$x = __sech__($$x);
    $x;
}

sub asec {
    require Math::AnyNum::asec;
    my ($x) = @_;
    $$x = __asec__($$x);
    $x;
}

sub asech {
    require Math::AnyNum::asech;
    my ($x) = @_;
    $$x = __asech__($$x);
    $x;
}

#
## csc / csch / acsc / acsch
#

sub csc {
    require Math::AnyNum::csc;
    my ($x) = @_;
    $$x = __csc__($$x);
    $x;
}

sub csch {
    require Math::AnyNum::csch;
    my ($x) = @_;
    $$x = __csch__($$x);
    $x;
}

sub acsc {
    require Math::AnyNum::acsc;
    my ($x) = @_;
    $$x = __acsc__($$x);
    $x;
}

sub acsch {
    require Math::AnyNum::acsch;
    my ($x) = @_;
    $$x = __acsch__($$x);
    $x;
}

#
## cot / coth / acot / acoth
#

sub cot {
    require Math::AnyNum::cot;
    my ($x) = @_;
    $$x = __cot__($$x);
    $x;
}

sub coth {
    require Math::AnyNum::coth;
    my ($x) = @_;
    $$x = __coth__($$x);
    $x;
}

sub acot {
    require Math::AnyNum::acot;
    my ($x) = @_;
    $$x = __acot__($$x);
    $x;
}

sub acoth {
    require Math::AnyNum::acoth;
    my ($x) = @_;
    $$x = __acoth__($$x);
    $x;
}

#
## gamma
#

sub gamma {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_gamma($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## lngamma
#

sub lngamma {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_lngamma($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## digamma
#

sub digamma {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_digamma($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## zeta
#

sub zeta {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_zeta($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## eta
#

sub eta {
    require Math::AnyNum::eta;
    my ($x) = @_;
    $$x = __eta__(_any2mpfr($$x));
    $x;
}

#
## beta
#
Class::Multimethods::multimethod beta => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::beta;
    my ($x, $y) = @_;
    $$x = __beta__(_any2mpfr($$x), _any2mpfr($$y));
    $x;
};

Class::Multimethods::multimethod beta => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &beta;
};

#
## Airy function (Ai)
#

sub Ai {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_ai($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Exponential integral (Ei)
#

sub Ei {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_eint($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Logarithmic integral (Li)
#
sub Li {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_log($f, $f, $ROUND);
    Math::MPFR::Rmpfr_eint($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Dilogarithm function (Li_2)
#
sub Li2 {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_li2($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Error function
#
sub erf {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_erf($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Complementary error function
#
sub erfc {
    my ($x) = @_;
    my $f = _any2mpfr($$x);
    Math::MPFR::Rmpfr_erfc($f, $f, $ROUND);
    $$x = $f;
    $x;
}

#
## Lambert W
#

sub lambert_w {
    require Math::AnyNum::lambert_w;
    my ($x) = @_;
    $$x = __lambert_w__(ref($$x) eq 'Math::MPC' ? $$x : _any2mpfr($$x));
    $x;
}

#
## lgrt -- logarithmic root
#

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
## RAND / IRAND
#

{
    my $srand = srand();

    {
        state $state = Math::MPFR::Rmpfr_randinit_mt_nobless();
        Math::MPFR::Rmpfr_randseed_ui($state, $srand);

        Class::Multimethods::multimethod rand => qw(Math::AnyNum) => sub {
            require Math::AnyNum::mul;

            my ($x) = @_;

            my $rand = Math::MPFR::Rmpfr_init2($PREC);
            Math::MPFR::Rmpfr_urandom($rand, $state, $ROUND);
            $rand = __mul__($rand, $$x);

            bless \$rand, __PACKAGE__;
        };

        Class::Multimethods::multimethod rand => qw(Math::AnyNum Math::AnyNum) => sub {
            require Math::AnyNum::mul;
            require Math::AnyNum::sub;
            require Math::AnyNum::add;

            my ($x, $y) = @_;

            my $rand = Math::MPFR::Rmpfr_init2($PREC);
            Math::MPFR::Rmpfr_urandom($rand, $state, $ROUND);
            $rand = __mul__($rand, __sub__(${$x->copy}, $$y));
            $rand = __add__($rand, $$x);

            bless \$rand, __PACKAGE__;
        };

        Class::Multimethods::multimethod rand => qw(Math::AnyNum *) => sub {
            (@_) = ($_[0], __PACKAGE__->new($_[1]));
            goto &rand;
        };

        Class::Multimethods::multimethod rand => qw(* Math::AnyNum) => sub {
            (@_) = (__PACKAGE__->new($_[0]), $_[1]);
            goto &rand;
        };

        Class::Multimethods::multimethod rand => qw(* *) => sub {
            (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]));
            goto &rand;
        };

        Class::Multimethods::multimethod rand => qw(*) => sub {
            (@_) = (__PACKAGE__->new($_[0]));
            goto &rand;
        };

=head2 seed

    $n->seed                       # => GMPz

Reseeds the C<rand()> method with the value of C<n>, where C<n> can be any arbitrary large integer.

Returns back the original value of C<n>.

=cut

        sub seed {
            my $z = _any2mpz($_[0]) // die "invalid seed: <<$_[0]>> (expected an integer)";
            Math::MPFR::Rmpfr_randseed($state, $z);
            bless \$z, __PACKAGE__;
        }
    }

=head2 irand

    $x->irand                      # => GMPz
    $x->irand(BigNum)              # => GMPz
    $x->irand(Scalar)              # => GMPz

Returns a pseudorandom integer. When an additional argument is provided, it returns
an integer between C<x> (inclusive) and C<y> (inclusive), otherwise returns an integer between C<0> (inclusive)
and C<x> (exclusive).

The PRNG behind this method is called the "Mersenne Twister".
Although it generates high-quality pseudorandom integers, it is B<NOT> cryptographically secure!

Example:

    10->irand        # a random integer between 0 and 10 (inclusive)
    10->irand(20)    # a random integer between 10 and 20 (inclusive)

=cut

    {
        state $state = Math::GMPz::zgmp_randinit_mt_nobless();
        Math::GMPz::zgmp_randseed_ui($state, $srand);

        Class::Multimethods::multimethod irand => qw(Math::AnyNum) => sub {
            my ($x) = @_;

            my $z = _any2mpz($$x) // (goto &nan);
            my $sgn = Math::GMPz::Rmpz_sgn($z) || do {
                my $r = Math::GMPz::Rmpz_init_set_ui(0);
                return bless \$r, __PACKAGE__;
            };

            Math::GMPz::Rmpz_urandomm($z, $state, $z, 1);
            Math::GMPz::Rmpz_neg($z, $z) if $sgn < 0;
            bless \$z, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(Math::AnyNum Math::AnyNum) => sub {
            my ($x, $y) = @_;

            my $z    = _any2mpz($$x) // (goto &nan);
            my $rand = _any2mpz($$y) // (goto &nan);

            my $r = Math::GMPz::Rmpz_init();
            my $cmp = Math::GMPz::Rmpz_cmp($rand, $z);

            if ($cmp == 0) {
                Math::GMPz::Rmpz_set($r, $z);
                return bless \$r, __PACKAGE__;
            }
            elsif ($cmp < 0) {
                ($z, $rand) = ($rand, $z);
            }

            Math::GMPz::Rmpz_sub($r, $rand, $z);
            Math::GMPz::Rmpz_add_ui($r, $r, 1);
            Math::GMPz::Rmpz_urandomm($r, $state, $r, 1);
            Math::GMPz::Rmpz_add($r, $r, $z);
            bless \$r, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(Math::AnyNum *) => sub {
            (@_) = ($_[0], __PACKAGE__->new($_[1]));
            goto &irand;
        };

        Class::Multimethods::multimethod irand => qw(* Math::AnyNum) => sub {
            (@_) = (__PACKAGE__->new($_[0]), $_[1]);
            goto &irand;
        };

        Class::Multimethods::multimethod irand => qw(* *) => sub {
            (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]));
            goto &irand;
        };

        Class::Multimethods::multimethod irand => qw(*) => sub {
            (@_) = (__PACKAGE__->new($_[0]));
            goto &irand;
        };

=head2 iseed

    $n->iseed                      # => GMPz

Reseeds the C<irand()> method with the value of C<n>, where C<n> can be any arbitrary large integer.

Returns back the original value of C<n>.

=cut

        sub iseed {
            my $z = _any2mpz($_[0]) // die "invalid seed: <<$_[0]>> (expected an integer)";
            Math::GMPz::zgmp_randseed($state, $z);
            bless \$z, __PACKAGE__;
        }
    }
}

#
## Fibonacci
#
sub fibonacci {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_fib_ui($z, CORE::int($x));
            return bless \$z, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->fibonacci;
    }

    my $ui = _any2ui($$x) // (goto &nan);
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_fib_ui($z, $ui);
    bless \$z, __PACKAGE__;
}

#
## Lucas
#
sub lucas {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_lucnum_ui($z, CORE::int($x));
            return bless \$z, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->lucas;
    }

    my $ui = _any2ui($$x) // (goto &nan);
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_lucnum_ui($z, $ui);
    bless \$z, __PACKAGE__;
}

#
## Primorial
#
sub primorial {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_primorial_ui($z, CORE::int($x));
            return bless \$z, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->primorial;
    }

    my $ui = _any2ui($$x) // (goto &nan);
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_primorial_ui($z, $ui);
    bless \$z, __PACKAGE__;
}

#
## bernfrac
#

sub bernfrac {
    require Math::AnyNum::bernfrac;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $q = __bernfrac__(CORE::int($x));
            return bless \$q, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->bernfrac;
    }

    my $n = _any2ui($$x) // goto &nan;
    my $q = __bernfrac__($n);
    bless \$q, __PACKAGE__;
}

#
## bernreal
#

sub bernreal {
    require Math::AnyNum::bernreal;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $f = __bernreal__(CORE::int($x));
            return bless \$f, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->bernreal;
    }

    my $n = _any2ui($$x) // goto &nan;
    my $f = __bernreal__($n);
    bless \$f, __PACKAGE__;
}

#
## Factorial
#
sub factorial {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_fac_ui($z, CORE::int($x));
            return bless \$z, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->factorial;
    }

    my $ui = _any2ui($$x) // (goto &nan);
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_fac_ui($z, $ui);
    bless \$z, __PACKAGE__;
}

#
## GCD
#

Class::Multimethods::multimethod gcd => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2mpz($$x) // (goto &nan);
    my $z = _any2mpz($$y) // (goto &nan);

    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_gcd($r, $n, $z);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod gcd => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &gcd;
};

Class::Multimethods::multimethod gcd => qw(* Math::AnyNum) => sub {
    (@_) = (__PACKAGE__->new($_[0]), $_[1]);
    goto &gcd;
};

Class::Multimethods::multimethod gcd => qw(* *) => sub {
    (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]));
    goto &gcd;
};

#
## Invmod
#

Class::Multimethods::multimethod invmod => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2mpz($$x) // (goto &nan);
    my $z = _any2mpz($$y) // (goto &nan);

    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_invert($r, $n, $z) || (goto &nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod invmod => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &invmod;
};

Class::Multimethods::multimethod invmod => qw(* Math::AnyNum) => sub {
    (@_) = (__PACKAGE__->new($_[0]), $_[1]);
    goto &invmod;
};

Class::Multimethods::multimethod invmod => qw(* *) => sub {
    (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]));
    goto &invmod;
};

#
## Powmod
#

Class::Multimethods::multimethod powmod => qw(Math::AnyNum Math::AnyNum Math::AnyNum) => sub {
    my ($n, $m, $o) = @_;

    my $x = _any2mpz($$n) // (goto &nan);
    my $y = _any2mpz($$m) // (goto &nan);
    my $z = _any2mpz($$o) // (goto &nan);

    Math::GMPz::Rmpz_sgn($z) || (goto &nan);

    my $r = Math::GMPz::Rmpz_init();

    if (Math::GMPz::Rmpz_sgn($y) < 0) {
        Math::GMPz::Rmpz_gcd($r, $x, $z);
        Math::GMPz::Rmpz_cmp_ui($r, 1) == 0 or (goto &nan);
    }

    Math::GMPz::Rmpz_powm($r, $x, $y, $z);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum * Math::AnyNum) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]), $_[2]);
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum Math::AnyNum *) => sub {
    (@_) = ($_[0], $_[1], __PACKAGE__->new($_[2]));
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum * *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]), __PACKAGE__->new($_[2]));
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(* Math::AnyNum *) => sub {
    (@_) = (__PACKAGE__->new($_[0]), $_[1], __PACKAGE__->new($_[2]));
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(* Math::AnyNum Math::AnyNum) => sub {
    (@_) = (__PACKAGE__->new($_[0]), $_[1], $_[2]);
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(* * Math::AnyNum) => sub {
    (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]), $_[2]);
    goto &powmod;
};

Class::Multimethods::multimethod powmod => qw(* * *) => sub {
    (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]), __PACKAGE__->new($_[2]));
    goto &powmod;
};

#
## Binomial
#

Class::Multimethods::multimethod binomial => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2si($$y)  // (goto &nan);
    my $z = _any2mpz($$x) // (goto &nan);

    my $r = Math::GMPz::Rmpz_init();

    $n < 0
      ? Math::GMPz::Rmpz_bin_si($r, $z, $n)
      : Math::GMPz::Rmpz_bin_ui($r, $z, $n);

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod binomial => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _any2mpz($$x) // (goto &nan);
        my $r = Math::GMPz::Rmpz_init();

        $y < 0
          ? Math::GMPz::Rmpz_bin_si($r, $z, $y)
          : Math::GMPz::Rmpz_bin_ui($r, $z, $y);

        bless \$r, __PACKAGE__;
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

Class::Multimethods::multimethod binomial => qw(* *) => sub {
    (@_) = (__PACKAGE__->new($_[0]), __PACKAGE__->new($_[1]));
    goto &binomial;
};

#
## AND
#

Class::Multimethods::multimethod and => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $z = _any2mpz($$x) // (goto &to_nan);
    my $n = _any2mpz($$y) // (goto &to_nan);

    Math::GMPz::Rmpz_and($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod and => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &and;
};

#
## OR
#

Class::Multimethods::multimethod or => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $z = _any2mpz($$x) // (goto &to_nan);
    my $n = _any2mpz($$y) // (goto &to_nan);

    Math::GMPz::Rmpz_ior($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod or => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &or;
};

#
## XOR
#

Class::Multimethods::multimethod xor => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $z = _any2mpz($$x) // (goto &to_nan);
    my $n = _any2mpz($$y) // (goto &to_nan);

    Math::GMPz::Rmpz_xor($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod xor => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &xor;
};

#
## NOT
#

sub not {
    my ($x) = @_;
    my $z = _any2mpz($$x) // (goto &to_nan);
    Math::GMPz::Rmpz_com($z, $z);
    $$x = $z;
    $x;
}

#
## LEFT SHIFT
#

Class::Multimethods::multimethod lsft => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2si($$y)  // (goto &to_nan);
    my $z = _any2mpz($$x) // (goto &to_nan);

    $n < 0
      ? Math::GMPz::Rmpz_div_2exp($z, $z, -$n)
      : Math::GMPz::Rmpz_mul_2exp($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod lsft => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _any2mpz($$x) // (goto &to_nan);

        $y < 0
          ? Math::GMPz::Rmpz_div_2exp($z, $z, -$y)
          : Math::GMPz::Rmpz_mul_2exp($z, $z, $y);

        $$x = $z;
        $x;
    }
    else {
        (@_) = ($x, __PACKAGE__->new($y));
        goto &lsft;
    }
};

Class::Multimethods::multimethod lsft => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &lsft;
};

#
## RIGHT SHIFT
#

Class::Multimethods::multimethod rsft => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2si($$y)  // (goto &to_nan);
    my $z = _any2mpz($$x) // (goto &to_nan);

    $n < 0
      ? Math::GMPz::Rmpz_mul_2exp($z, $z, -$n)
      : Math::GMPz::Rmpz_div_2exp($z, $z, $n);

    $$x = $z;
    $x;
};

Class::Multimethods::multimethod rsft => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _any2mpz($$x) // (goto &to_nan);

        $y < 0
          ? Math::GMPz::Rmpz_mul_2exp($z, $z, -$y)
          : Math::GMPz::Rmpz_div_2exp($z, $z, $y);

        $$x = $z;
        $x;
    }
    else {
        (@_) = ($x, __PACKAGE__->new($y));
        goto &rsft;
    }
};

Class::Multimethods::multimethod rsft => qw(Math::AnyNum *) => sub {
    (@_) = ($_[0], __PACKAGE__->new($_[1]));
    goto &rsft;
};

#
## POPCOUNT
#

sub popcount {
    my ($x) = @_;
    my $z = _any2mpz($$x) // return -1;
    if (Math::GMPz::Rmpz_sgn($z) < 0) {
        my $t = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_neg($t, $z);
        $z = $t;
    }
    Math::GMPz::Rmpz_popcount($z);
}

#
## Introspection
#

sub as_bin {
    my ($x) = @_;
    my $z = _any2mpz($$x) // return;
    Math::GMPz::Rmpz_get_str($z, 2);
}

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
