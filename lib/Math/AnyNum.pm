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

our $VERSION = '0.04';
our ($ROUND, $PREC);

BEGIN {
    $ROUND = Math::MPFR::MPFR_RNDN();
    $PREC  = 192;
}

BEGIN {
    use Math::GMPz::V qw();

    state $GMP_V_MAJOR = Math::GMPz::V::___GNU_MP_VERSION();
    state $GMP_V_MINOR = Math::GMPz::V::___GNU_MP_VERSION_MINOR();

    # Rmpq_cmp_z() is available only in gmp>=6.1.0
    # https://rt.cpan.org/Public/Bug/Display.html?id=120910
    if ($GMP_V_MAJOR < 6 or ($GMP_V_MAJOR == 6 and $GMP_V_MINOR < 1)) {
        no warnings 'redefine';
        *Math::GMPq::Rmpq_cmp_z = sub {
            my ($q1, $z) = @_;
            my $q2 = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_z($q2, $z);
            Math::GMPq::Rmpq_cmp($q1, $q2);
        };
    }
}

use overload
  '""' => \&stringify,
  '0+' => \&numify,
  bool => \&boolify,

  '+' => sub { $_[0]->add($_[1]) },
  '*' => sub { $_[0]->mul($_[1]) },

  '==' => sub { $_[0]->eq($_[1]) },
  '!=' => sub { $_[0]->ne($_[1]) },

  '&' => sub { $_[0]->and($_[1]) },
  '|' => sub { $_[0]->or($_[1]) },
  '^' => sub { $_[0]->xor($_[1]) },
  '~' => \&not,

#<<<
  '>'   => sub { $_[2] ?   $_[0]->lt ($_[1])  : $_[0]->gt ($_[1]) },
  '>='  => sub { $_[2] ?   $_[0]->le ($_[1])  : $_[0]->ge ($_[1]) },
  '<'   => sub { $_[2] ?   $_[0]->gt ($_[1])  : $_[0]->lt ($_[1]) },
  '<='  => sub { $_[2] ?   $_[0]->ge ($_[1])  : $_[0]->le ($_[1]) },
  '<=>' => sub { $_[2] ? -($_[0]->cmp($_[1]) // return undef) : $_[0]->cmp($_[1]) },
#>>>

  '>>' => sub { $_[2] ? __PACKAGE__->new($_[1])->rsft($_[0]) : $_[0]->rsft($_[1]) },
  '<<' => sub { $_[2] ? __PACKAGE__->new($_[1])->lsft($_[0]) : $_[0]->lsft($_[1]) },

  '**' => sub { $_[2] ? __PACKAGE__->new($_[1])->pow($_[0]) : $_[0]->pow($_[1]) },
  '%'  => sub { $_[2] ? __PACKAGE__->new($_[1])->mod($_[0]) : $_[0]->mod($_[1]) },

  #~ '/' => sub { $_[2] ? $_[0]->inv->mul($_[1]) : $_[0]->div($_[1]) },
  #~ '-' => sub { $_[2] ? $_[0]->neg->add($_[1]) : $_[0]->sub($_[1]) },

  '/' => sub { $_[2] ? __PACKAGE__->new($_[1])->div($_[0]) : $_[0]->div($_[1]) },
  '-' => sub { $_[2] ? __PACKAGE__->new($_[1])->sub($_[0]) : $_[0]->sub($_[1]) },

  atan2 => sub { &Math::AnyNum::atan2($_[2] ? ($_[1], $_[0]) : ($_[0], $_[1])) },

  eq => sub { "$_[0]" eq "$_[1]" },
  ne => sub { "$_[0]" ne "$_[1]" },

  cmp => sub { $_[2] ? ("$_[1]" cmp $_[0]->stringify) : ($_[0]->stringify cmp "$_[1]") },

  neg  => \&neg,
  sin  => \&sin,
  cos  => \&cos,
  exp  => \&exp,
  log  => \&ln,
  int  => \&int,
  abs  => \&abs,
  sqrt => \&sqrt;

{

    my %const = (    # prototypes are assigned in import()
                  e       => \&e,
                  phi     => \&phi,
                  tau     => \&tau,
                  pi      => \&pi,
                  ln2     => \&ln2,
                  euler   => \&euler,
                  i       => \&i,
                  catalan => \&catalan,
                  Inf     => \&inf,
                  NaN     => \&nan,
                );

    my %trig = (
        sin   => sub (_) { goto &sin },
        sinh  => sub ($) { goto &sinh },
        asin  => sub ($) { goto &asin },
        asinh => sub ($) { goto &asinh },

        cos   => sub (_) { goto &cos },     # built-in keyword
        cosh  => sub ($) { goto &cosh },
        acos  => sub ($) { goto &acos },
        acosh => sub ($) { goto &acosh },

        tan   => sub ($) { goto &tan },
        tanh  => sub ($) { goto &tanh },
        atan  => sub ($) { goto &atan },
        atanh => sub ($) { goto &atanh },

        cot   => sub ($) { goto &cot },
        coth  => sub ($) { goto &coth },
        acot  => sub ($) { goto &acot },
        acoth => sub ($) { goto &acoth },

        sec   => sub ($) { goto &sec },
        sech  => sub ($) { goto &sech },
        asec  => sub ($) { goto &asec },
        asech => sub ($) { goto &asech },

        csc   => sub ($) { goto &csc },
        csch  => sub ($) { goto &csch },
        acsc  => sub ($) { goto &acsc },
        acsch => sub ($) { goto &acsch },

        atan2   => sub ($$) { goto &atan2 },
        deg2rad => sub ($)  { goto &deg2rad },
        rad2deg => sub ($)  { goto &rad2deg },
               );

    my %special = (
                   beta     => sub ($$)  { goto &beta },
                   zeta     => sub ($)   { goto &zeta },
                   eta      => sub ($)   { goto &eta },
                   gamma    => sub ($)   { goto &gamma },
                   lgamma   => sub ($)   { goto &lgamma },
                   lngamma  => sub ($)   { goto &lngamma },
                   digamma  => sub ($)   { goto &digamma },
                   Ai       => sub ($)   { goto &Ai },
                   Ei       => sub ($)   { goto &Ei },
                   Li       => sub ($)   { goto &Li },
                   Li2      => sub ($)   { goto &Li2 },
                   LambertW => sub ($)   { goto &LambertW },
                   BesselJ  => sub ($$)  { goto &BesselJ },
                   BesselY  => sub ($$)  { goto &BesselY },
                   lgrt     => sub ($)   { goto &lgrt },
                   pow      => sub ($$)  { goto &pow },
                   sqr      => sub ($)   { goto &sqr },
                   sqrt     => sub (_)   { goto &sqrt },       # built-in keyword
                   cbrt     => sub ($)   { goto &cbrt },
                   root     => sub ($$)  { goto &root },
                   exp      => sub (_)   { goto &exp },        # built-in keyword
                   ln       => sub ($)   { goto &ln },
                   log      => sub (_;$) { goto &log },        # built-in keyword
                   log10    => sub ($)   { goto &log10 },
                   log2     => sub ($)   { goto &log2 },
                   mod      => sub ($$)  { goto &mod },
                   abs      => sub (_)   { goto &abs },        # built-in keyword
                   erf      => sub ($)   { goto &erf },
                   erfc     => sub ($)   { goto &erfc },
                   hypot    => sub ($$)  { goto &hypot },
                   agm      => sub ($$)  { goto &agm },
                   bernreal => sub ($)   { goto &bernreal },
                   harmreal => sub ($)   { goto &harmreal },
                  );

    my %ntheory = (
        factorial  => sub ($)  { goto &factorial },
        dfactorial => sub ($)  { goto &dfactorial },
        mfactorial => sub ($$) { goto &mfactorial },
        primorial  => sub ($)  { goto &primorial },
        binomial   => sub ($$) { goto &binomial },

        lucas     => sub ($) { goto &lucas },
        fibonacci => sub ($) { goto &fibonacci },

        bernfrac => sub ($) { goto &bernfrac },
        harmfrac => sub ($) { goto &harmfrac },

        lcm       => sub ($$) { goto &lcm },
        gcd       => sub ($$) { goto &gcd },
        valuation => sub ($$) { goto &valuation },
        kronecker => sub ($$) { goto &kronecker },

        remdiv => sub ($$) { goto &remdiv },
        divmod => sub ($$) { goto &divmod },

        iadd => sub ($$) { goto &iadd },
        isub => sub ($$) { goto &isub },
        imul => sub ($$) { goto &imul },
        idiv => sub ($$) { goto &idiv },
        imod => sub ($$) { goto &imod },

        ipow  => sub ($$) { goto &ipow },
        iroot => sub ($$) { goto &iroot },
        isqrt => sub ($)  { goto &isqrt },
        icbrt => sub ($)  { goto &icbrt },

        ilog   => sub ($;$) { goto &ilog },
        ilog2  => sub ($)   { goto &ilog2 },
        ilog10 => sub ($)   { goto &ilog10 },

        isqrtrem => sub ($)  { goto &isqrtrem },
        irootrem => sub ($$) { goto &irootrem },

        powmod => sub ($$$) { goto &powmod },
        invmod => sub ($$)  { goto &invmod },

        is_power   => sub ($;$) { goto &is_power },
        is_square  => sub ($)   { goto &is_square },
        is_prime   => sub ($;$) { goto &is_prime },
        next_prime => sub ($)   { goto &next_prime },
                  );

    my %misc = (
        rand => sub (;$;$) {
            @_ ? (goto &rand) : do { (@_) = (1); goto &rand }
        },
        irand => sub ($;$) { goto &irand },

        seed  => sub ($) { goto &seed },
        iseed => sub ($) { goto &iseed },

        floor => sub ($)   { goto &floor },
        ceil  => sub ($)   { goto &ceil },
        round => sub ($;$) { goto &round },
        sgn   => sub ($)   { goto &sgn },

        popcount => sub ($) { goto &popcount },

        real => sub ($) { goto &real },
        imag => sub ($) { goto &imag },

        int     => sub (_) { goto &int },       # built-in keyword
        rat     => sub ($) { goto &rat },
        float   => sub ($) { goto &float },
        complex => sub ($) { goto &complex },

        numerator   => sub ($) { goto &numerator },
        denominator => sub ($) { goto &denominator },

        digits => sub ($;$) { goto &digits },

        as_bin  => sub ($)   { goto &as_bin },
        as_hex  => sub ($)   { goto &as_hex },
        as_oct  => sub ($)   { goto &as_oct },
        as_int  => sub ($;$) { goto &as_int },
        as_frac => sub ($)   { goto &as_frac },

        is_inf     => sub ($) { goto &is_inf },
        is_ninf    => sub ($) { goto &is_ninf },
        is_neg     => sub ($) { goto &is_neg },
        is_pos     => sub ($) { goto &is_pos },
        is_nan     => sub ($) { goto &is_nan },
        is_rat     => sub ($) { goto &is_rat },
        is_real    => sub ($) { goto &is_real },
        is_imag    => sub ($) { goto &is_imag },
        is_int     => sub ($) { goto &is_int },
        is_complex => sub ($) { goto &is_complex },
        is_zero    => sub ($) { goto &is_zero },
        is_one     => sub ($) { goto &is_one },
        is_mone    => sub ($) { goto &is_mone },

        is_odd  => sub ($)  { goto &is_odd },
        is_even => sub ($)  { goto &is_even },
        is_div  => sub ($$) { goto &is_div },
               );

    sub import {
        shift;

        my $caller = caller(0);

        while (@_) {
            my $name = shift(@_);

            if ($name eq ':overload') {
                overload::constant
                  integer => sub { __PACKAGE__->new_ui($_[0]) },
                  float   => sub { __PACKAGE__->new_f($_[0]) },
                  binary  => sub {
                    my ($const) = @_;
                    my $prefix = substr($const, 0, 2);
                        $prefix eq '0x' ? __PACKAGE__->new(substr($const, 2), 16)
                      : $prefix eq '0b' ? __PACKAGE__->new(substr($const, 2), 2)
                      :                   __PACKAGE__->new(substr($const, 1), 8);
                  };

                # Export 'Inf', 'NaN' and 'i' as constants
                foreach my $pair (['Inf', inf()], ['NaN', nan()], ['i', i()]) {
                    my $sub = $caller . '::' . $pair->[0];
                    no strict 'refs';
                    no warnings 'redefine';
                    my $value = $pair->[1];
                    *$sub = sub () { $value };
                }
            }
            elsif (exists $const{$name}) {
                no strict 'refs';
                no warnings 'redefine';
                my $caller_sub = $caller . '::' . $name;
                my $sub        = $const{$name};
                my $value      = $sub->();
                *$caller_sub = sub() { $value }
            }
            elsif (   exists($special{$name})
                   or exists($trig{$name})
                   or exists($ntheory{$name})
                   or exists($misc{$name})) {
                no strict 'refs';
                no warnings 'redefine';
                my $caller_sub = $caller . '::' . $name;
                *$caller_sub = $ntheory{$name} // $special{$name} // $trig{$name} // $misc{$name};
            }
            elsif ($name eq ':trig') {
                push @_, keys(%trig);
            }
            elsif ($name eq ':ntheory') {
                push @_, keys(%ntheory);
            }
            elsif ($name eq ':special') {
                push @_, keys(%special);
            }
            elsif ($name eq ':misc') {
                push @_, keys(%misc);
            }
            elsif ($name eq ':all') {
                push @_, keys(%const), keys(%trig), keys(%special), keys(%ntheory), keys(%misc);
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

        $s < 0
          ? Math::GMPz::Rmpz_set_si($r, $s)
          : Math::GMPz::Rmpz_set_ui($r, $s);

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

    $s =~ s/^\+//;

    my $r = Math::GMPz::Rmpz_init();
    eval { Math::GMPz::Rmpz_set_str($r, $s, 10); 1 } // do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        return $r;
    };
    return $r;
}

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

    if (Math::MPFR::Rmpfr_zero_p($fr)) {
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
        if (Math::MPFR::Rmpfr_number_p($x)) {
            my $d = CORE::int(Math::MPFR::Rmpfr_get_d($x, $ROUND));
            ($d < 0 or $d > ULONG_MAX) && return;
            return $d;
        }
        return;
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
        if (Math::MPFR::Rmpfr_number_p($x)) {
            my $d = CORE::int(Math::MPFR::Rmpfr_get_d($x, $ROUND));
            ($d < LONG_MIN or $d > ULONG_MAX) && return;
            return $d;
        }
        return;
    }

    (@_) = _any2mpfr($x);
    goto &_any2si;
}

#
## Anything to MPFR (including scalars)
#
sub _star2mpfr {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = $$x;
    }
    else {
        $x = ref($x) ? ${__PACKAGE__->new($x)} : _str2obj($x);

        if (ref($x) eq 'Math::MPFR') {
            return $x;
        }
    }

    if (ref($x) eq 'Math::MPFR') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set($r, $x, $ROUND);
        return $r;
    }

    (@_) = $x;
    ref($x) eq 'Math::GMPz' && goto &_mpz2mpfr;
    ref($x) eq 'Math::GMPq' && goto &_mpq2mpfr;
    goto &_any2mpfr;
}

#
## Anything to GMPz (including scalars)
#
sub _star2mpz {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = $$x;
    }
    else {
        $x = ref($x) ? ${__PACKAGE__->new($x)} : _str2obj($x);

        if (ref($x) eq 'Math::GMPz') {
            return $x;
        }
    }

    if (ref($x) eq 'Math::GMPz') {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set($r, $x);
        return $r;
    }

    (@_) = $x;
    ref($x) eq 'Math::GMPq' and goto &_mpq2mpz;
    goto &_any2mpz;
}

#
## Internal Math::AnyNum object as a GMPz copy
#

sub _copy2mpz {
    my ($x) = @_;

    if (ref($x) eq 'Math::GMPz') {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set($r, $x);
        return $r;
    }

    ref($x) eq 'Math::GMPq' and goto &_mpq2mpz;
    goto &_any2mpz;
}

#
## Anything to MPFR or MPC, in this order (including scalars)
#
sub _star2mpfr_mpc {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = $$x;
    }
    else {
        $x = ref($x) ? ${__PACKAGE__->new($x)} : _str2obj($x);

        if (   ref($x) eq 'Math::MPFR'
            or ref($x) eq 'Math::MPC') {
            return $x;
        }
    }

    if (ref($x) eq 'Math::MPFR') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set($r, $x, $ROUND);
        return $r;
    }
    elsif (ref($x) eq 'Math::MPC') {
        my $r = Math::MPC::Rmpc_init2($PREC);
        Math::MPC::Rmpc_set($r, $x, $ROUND);
        return $r;
    }

    (@_) = $x;
    ref($x) eq 'Math::GMPz' && goto &_mpz2mpfr;
    ref($x) eq 'Math::GMPq' && goto &_mpq2mpfr;
    goto &_any2mpfr;    # this should not happen
}

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

sub new_si {
    my (undef, $si) = @_;
    my $r = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_set_si($r, $si);
    bless \$r, __PACKAGE__;
}

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
    state $nan = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        $r;
    };
}

sub nan {
    state $nan = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_nan($r);
        bless \$r, __PACKAGE__;
    };
}

sub _inf {
    state $inf = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, 1);
        $r;
    };
}

sub inf {
    state $inf = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, 1);
        bless \$r, __PACKAGE__;
    };
}

sub _ninf {
    state $ninf = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, -1);
        $r;
    };
}

sub ninf {
    state $ninf = do {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set_inf($r, -1);
        bless \$r, __PACKAGE__;
    };
}

sub _zero {
    state $zero = Math::GMPz::Rmpz_init_set_ui(0);
}

sub zero {
    state $zero = do {
        my $r = Math::GMPz::Rmpz_init_set_ui(0);
        bless \$r, __PACKAGE__;
    };
}

sub _one {
    state $one = Math::GMPz::Rmpz_init_set_ui(1);
}

sub one {
    state $one = do {
        my $r = Math::GMPz::Rmpz_init_set_ui(1);
        bless \$r, __PACKAGE__;
    };
}

sub _mone {
    state $mone = Math::GMPz::Rmpz_init_set_si(-1);
}

sub mone {
    state $mone = do {
        my $r = Math::GMPz::Rmpz_init_set_si(-1);
        bless \$r, __PACKAGE__;
    };
}

#
## CONSTANTS
#

sub pi {
    my $pi = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($pi, $ROUND);
    bless \$pi, __PACKAGE__;
}

sub tau {
    my $tau = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($tau, $ROUND);
    Math::MPFR::Rmpfr_mul_ui($tau, $tau, 2, $ROUND);
    bless \$tau, __PACKAGE__;
}

sub ln2 {
    my $ln2 = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_log2($ln2, $ROUND);
    bless \$ln2, __PACKAGE__;
}

sub euler {
    my $euler = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_euler($euler, $ROUND);
    bless \$euler, __PACKAGE__;
}

sub catalan {
    my $catalan = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_catalan($catalan, $ROUND);
    bless \$catalan, __PACKAGE__;
}

sub i {
    my $i = Math::MPC::Rmpc_init2($PREC);
    Math::MPC::Rmpc_set_ui_ui($i, 0, 1, $ROUND);
    bless \$i, __PACKAGE__;
}

sub e {
    state $one_f = (Math::MPFR::Rmpfr_init_set_ui_nobless(1, $ROUND))[0];
    my $e = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_exp($e, $one_f, $ROUND);
    bless \$e, __PACKAGE__;
}

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

Class::Multimethods::multimethod eq => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::eq;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        __eq__($$x, $y);
    }
    else {
        __eq__($$x, _str2obj($y));
    }
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

Class::Multimethods::multimethod ne => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::ne;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        __ne__($$x, $y);
    }
    else {
        __ne__($$x, _str2obj($y));
    }
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

Class::Multimethods::multimethod cmp => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        (@_) = ($$x, $y);
        goto &__cmp__;
    }
    else {
        (@_) = ($$x, _str2obj($y));
        goto &__cmp__;
    }
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
    (__cmp__($$x, $$y) // return undef) > 0;
};

Class::Multimethods::multimethod gt => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        (__cmp__($$x, $y) // return undef) > 0;
    }
    else {
        (__cmp__($$x, _str2obj($y)) // return undef) > 0;
    }
};

Class::Multimethods::multimethod gt => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, ${__PACKAGE__->new($y)}) // return undef) > 0;
};

#
## GE
#

Class::Multimethods::multimethod ge => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, $$y) // return undef) >= 0;
};

Class::Multimethods::multimethod ge => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        (__cmp__($$x, $y) // return undef) >= 0;
    }
    else {
        (__cmp__($$x, _str2obj($y)) // return undef) >= 0;
    }
};

Class::Multimethods::multimethod ge => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, ${__PACKAGE__->new($y)}) // return undef) >= 0;
};

#
## LT
#
Class::Multimethods::multimethod lt => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, $$y) // return undef) < 0;
};

Class::Multimethods::multimethod lt => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        (__cmp__($$x, $y) // return undef) < 0;
    }
    else {
        (__cmp__($$x, _str2obj($y)) // return undef) < 0;
    }
};

Class::Multimethods::multimethod lt => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, ${__PACKAGE__->new($y)}) // return undef) < 0;
};

#
## LE
#
Class::Multimethods::multimethod le => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, $$y) // return undef) <= 0;
};

Class::Multimethods::multimethod le => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        (__cmp__($$x, $y) // return undef) <= 0;
    }
    else {
        (__cmp__($$x, _str2obj($y)) // return undef) <= 0;
    }
};

Class::Multimethods::multimethod le => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::cmp;
    my ($x, $y) = @_;
    (__cmp__($$x, ${__PACKAGE__->new($y)}) // return undef) <= 0;
};

sub _copy {
    my ($x) = @_;
    my $ref = ref($x);

    if ($ref eq 'Math::GMPz') {
        my $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_set($r, $x);
        return $r;
    }
    elsif ($ref eq 'Math::MPFR') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPFR::Rmpfr_set($r, $x, $ROUND);
        return $r;
    }
    elsif ($ref eq 'Math::GMPq') {
        my $r = Math::GMPq::Rmpq_init();
        Math::GMPq::Rmpq_set($r, $x);
        return $r;
    }
    elsif ($ref eq 'Math::MPC') {
        my $r = Math::MPC::Rmpc_init2($PREC);
        Math::MPC::Rmpc_set($r, $x, $ROUND);
        return $r;
    }

    ${__PACKAGE__->new($x)};    # this should not happen
}

sub copy {
    my ($x) = @_;
    my $r = _copy($$x);
    bless \$r, __PACKAGE__;
}

sub int {
    my ($x) = @_;
    if (ref($x) eq __PACKAGE__) {
        my $r = _any2mpz($$x) // (goto &nan);
        bless \$r, __PACKAGE__;
    }
    else {
        my $r = _star2mpz($x) // (goto &nan);
        bless \$r, __PACKAGE__;
    }
}

sub rat {
    my ($x) = @_;
    if (ref($x) eq __PACKAGE__) {
        my $r = _any2mpq($$x) // (goto &nan);
        bless \$r, __PACKAGE__;
    }
    else {
        my $r = __PACKAGE__->new($x);
        $$r = _any2mpq($$r) // goto(&nan);
        $r;
    }
}

sub float {
    my ($x) = @_;
    if (ref($x) eq __PACKAGE__) {
        my $r = _any2mpfr($$x);
        bless \$r, __PACKAGE__;
    }
    else {
        my $r = __PACKAGE__->new($x);
        $$r = _any2mpfr($$r);
        $r;
    }
}

sub complex {
    my ($x) = @_;
    if (ref($x) eq __PACKAGE__) {
        my $r = _any2mpc($$x);
        bless \$r, __PACKAGE__;
    }
    else {
        my $r = __PACKAGE__->new($x);
        $$r = _any2mpc($$r);
        $r;
    }
}

sub neg {
    require Math::AnyNum::neg;
    my ($x) = @_;
    my $r = __neg__(_copy($$x));
    bless \$r, __PACKAGE__;
}

sub abs {
    require Math::AnyNum::abs;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r = __abs__(ref($$x) eq 'Math::MPC' ? $$x : _copy($$x));
    bless \$r, __PACKAGE__;
}

sub inv {
    require Math::AnyNum::inv;
    my ($x) = @_;
    my $r = __inv__(_copy($$x));
    bless \$r, __PACKAGE__;
}

sub inc {
    require Math::AnyNum::inc;
    my ($x) = @_;
    my $r = __inc__(_copy($$x));
    bless \$r, __PACKAGE__;
}

sub dec {
    require Math::AnyNum::dec;
    my ($x) = @_;
    my $r = __dec__(_copy($$x));
    bless \$r, __PACKAGE__;
}

sub real {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    if (ref($$x) eq 'Math::MPC') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPC::RMPC_RE($r, $$x);
        return bless \$r, __PACKAGE__;
    }

    $x;
}

sub imag {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    if (ref($$x) eq 'Math::MPC') {
        my $r = Math::MPFR::Rmpfr_init2($PREC);
        Math::MPC::RMPC_IM($r, $$x);
        return bless \$r, __PACKAGE__;
    }

    goto &zero;
}

#
## ADD
#

Class::Multimethods::multimethod add => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::add;
    my ($x, $y) = @_;
    my $r = __add__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
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
            Math::GMPq::Rmpq_add($r, $r, $$x);
            return bless \$r, __PACKAGE__;
        }

        my $r = __add__(_copy($$x), $y);
        return bless \$r, __PACKAGE__;
    }

    my $r = __add__(_copy($$x), _str2obj($y));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod add => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::add;
    my ($x, $y) = @_;
    my $r = __add__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod sub => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::sub;
    my ($x, $y) = @_;
    my $r = __sub__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
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
            Math::GMPq::Rmpq_sub($r, $$x, $r);
            return bless \$r, __PACKAGE__;
        }

        my $r = __sub__(_copy($$x), $y);
        return bless \$r, __PACKAGE__;
    }

    my $r = __sub__(_copy($$x), _str2obj($y));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod sub => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::sub;
    my ($x, $y) = @_;
    my $r = __sub__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

#
## MULTIPLY
#

Class::Multimethods::multimethod mul => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::mul;
    my ($x, $y) = @_;
    my $r = __mul__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
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
            Math::GMPq::Rmpq_mul($r, $r, $$x);
            return bless \$r, __PACKAGE__;
        }

        my $r = __mul__(_copy($$x), $y);
        return bless \$r, __PACKAGE__;
    }

    my $r = __mul__(_copy($$x), _str2obj($y));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod mul => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::mul;
    my ($x, $y) = @_;
    my $r = __mul__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

#
## DIVISION
#

Class::Multimethods::multimethod div => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    my $r = __div__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod div => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN and CORE::int($y) != 0) {

        if (ref($$x) eq 'Math::GMPq') {
            my $r = Math::GMPq::Rmpq_init();
            $y < 0
              ? Math::GMPq::Rmpq_set_si($r, -1, -$y)
              : Math::GMPq::Rmpq_set_ui($r, 1, $y);
            Math::GMPq::Rmpq_mul($r, $r, $$x);
            return bless \$r, __PACKAGE__;
        }
        elsif (ref($$x) eq 'Math::GMPz') {
            my $r = Math::GMPq::Rmpq_init();
            Math::GMPq::Rmpq_set_ui($r, 1, CORE::abs($y));
            Math::GMPq::Rmpq_set_num($r, $$x);
            Math::GMPq::Rmpq_neg($r, $r) if $y < 0;
            Math::GMPq::Rmpq_canonicalize($r);
            return bless \$r, __PACKAGE__;
        }

        my $r = __div__(_copy($$x), $y);
        return bless \$r, __PACKAGE__;
    }

    my $r = __div__(_copy($$x), _str2obj($y));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod div => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    my $r = __div__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

#
## IADD
#

Class::Multimethods::multimethod iadd => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::iadd;
    my ($x, $y) = @_;
    my $r = __iadd__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iadd => qw(* $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and CORE::int($y) and CORE::abs($y) <= ULONG_MAX) {
        my $n = _star2mpz($x) // goto &nan;
        $y < 0
          ? Math::GMPz::Rmpz_sub_ui($n, $n, -$y)
          : Math::GMPz::Rmpz_add_ui($n, $n, $y);
        bless \$n, __PACKAGE__;
    }
    else {
        require Math::AnyNum::iadd;
        my $r = __iadd__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
        bless \$r, __PACKAGE__;
    }
};

Class::Multimethods::multimethod iadd => qw(* *) => sub {
    require Math::AnyNum::iadd;
    my ($x, $y) = @_;
    my $r = __iadd__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## ISUB
#

Class::Multimethods::multimethod isub => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::isub;
    my ($x, $y) = @_;
    my $r = __isub__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod isub => qw(* $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and CORE::int($y) and CORE::abs($y) <= ULONG_MAX) {
        my $n = _star2mpz($x) // goto &nan;
        $y < 0
          ? Math::GMPz::Rmpz_add_ui($n, $n, -$y)
          : Math::GMPz::Rmpz_sub_ui($n, $n, $y);
        bless \$n, __PACKAGE__;
    }
    else {
        require Math::AnyNum::isub;
        my $r = __isub__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
        bless \$r, __PACKAGE__;
    }
};

Class::Multimethods::multimethod isub => qw(* *) => sub {
    require Math::AnyNum::isub;
    my ($x, $y) = @_;
    my $r = __isub__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## IMUL
#

Class::Multimethods::multimethod imul => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::imul;
    my ($x, $y) = @_;
    my $r = __imul__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod imul => qw(* $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and CORE::int($y) and CORE::abs($y) <= ULONG_MAX) {
        my $n = _star2mpz($x) // goto &nan;
        Math::GMPz::Rmpz_mul_ui($n, $n, CORE::abs($y));
        Math::GMPz::Rmpz_neg($n, $n) if $y < 0;
        bless \$n, __PACKAGE__;
    }
    else {
        require Math::AnyNum::imul;
        my $r = __imul__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
        bless \$r, __PACKAGE__;
    }
};

Class::Multimethods::multimethod imul => qw(* *) => sub {
    require Math::AnyNum::imul;
    my ($x, $y) = @_;
    my $r = __imul__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## IDIV
#

Class::Multimethods::multimethod idiv => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::idiv;
    my ($x, $y) = @_;
    my $r = __idiv__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod idiv => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::idiv;
    my ($x, $y) = @_;
    my $r = __idiv__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod idiv => qw(* $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and CORE::int($y) and CORE::abs($y) <= ULONG_MAX) {
        my $n = _star2mpz($x) // goto &nan;
        Math::GMPz::Rmpz_tdiv_q_ui($n, $n, CORE::abs($y));
        Math::GMPz::Rmpz_neg($n, $n) if $y < 0;
        bless \$n, __PACKAGE__;
    }
    else {
        require Math::AnyNum::idiv;
        my $r = __idiv__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
        bless \$r, __PACKAGE__;
    }
};

Class::Multimethods::multimethod idiv => qw(* *) => sub {
    require Math::AnyNum::idiv;
    my ($x, $y) = @_;
    my $r = __idiv__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## POWER
#

Class::Multimethods::multimethod pow => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    my $r = __pow__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod pow => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        $r = __pow__(_copy($$x), $y);
    }
    else {
        $r = __pow__(_copy($$x), _str2obj($y));
    }
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod pow => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    my $r = __pow__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod pow => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    my $r = __pow__(${__PACKAGE__->new($x)}, $$y);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod pow => qw(* $) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        $r = __pow__(${__PACKAGE__->new($x)}, $y);
    }
    else {
        $r = __pow__(${__PACKAGE__->new($x)}, _str2obj($y));
    }
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod pow => qw(* *) => sub {
    require Math::AnyNum::pow;
    my ($x, $y) = @_;
    my $r = __pow__(${__PACKAGE__->new($x)}, ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

#
## INTEGER POWER
#

Class::Multimethods::multimethod ipow => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;
    my $r = __ipow__(_copy2mpz($$x) // (goto &nan), _any2si($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod ipow => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        $r = __ipow__(_copy2mpz($$x) // (goto &nan), $y);
    }
    else {
        $r = __ipow__(_copy2mpz($$x) // (goto &nan), _any2si(_str2obj($y)) // (goto &nan));
    }
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod ipow => qw($ $) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;

    my $r;
    if (    CORE::int($x) eq $x
        and $x >= 0
        and $x <= ULONG_MAX
        and CORE::int($y) eq $y
        and $y >= 0
        and $y <= ULONG_MAX) {
        $r = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_ui_pow_ui($r, $x, $y);
    }
    else {
        $r = __ipow__(_star2mpz($x) // (goto &nan), _any2si(_str2obj($y)) // goto &nan);
    }

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod ipow => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;
    my $r = __ipow__(_star2mpz($x) // (goto &nan), _any2si($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod ipow => qw(* *) => sub {
    require Math::AnyNum::ipow;
    my ($x, $y) = @_;
    my $r = __ipow__(_star2mpz($x) // (goto &nan), _any2si(${__PACKAGE__->new($y)}) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## ROOT
#

Class::Multimethods::multimethod root => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    my $r = __pow__(_copy($$x), __inv__(_copy($$y)));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod root => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    my $r = __pow__(_copy($$x), __inv__(_str2obj($y)));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod root => qw(* $) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    my $r = __pow__(${__PACKAGE__->new($x)}, __inv__(_str2obj($y)));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod root => qw(* *) => sub {
    require Math::AnyNum::pow;
    require Math::AnyNum::inv;
    my ($x, $y) = @_;
    my $r = __pow__(${__PACKAGE__->new($x)}, __inv__(${__PACKAGE__->new($y)}));
    bless \$r, __PACKAGE__;
};

#
## isqrt
#

sub isqrt {
    my $z = _star2mpz($_[0]) // goto &nan;
    Math::GMPz::Rmpz_sgn($z) < 0 and goto &nan;
    Math::GMPz::Rmpz_sqrt($z, $z);
    bless \$z, __PACKAGE__;
}

#
## icbrt
#

sub icbrt {
    require Math::AnyNum::iroot;
    my $r = __iroot__(_star2mpz($_[0]) // (goto &nan), 3);
    bless \$r, __PACKAGE__;
}

#
## IROOT
#
Class::Multimethods::multimethod iroot => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    my $r = __iroot__(_copy2mpz($$x) // (goto &nan), _any2si($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iroot => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        $r = __iroot__(_copy2mpz($$x) // (goto &nan), $y);
    }
    else {
        $r = __iroot__(_copy2mpz($$x) // (goto &nan), _any2si(_str2obj($y)) // (goto &nan));
    }

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iroot => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    my $r = __iroot__(_copy2mpz($$x) // (goto &nan), _any2si(${__PACKAGE__->new($y)}) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iroot => qw(* $) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        $r = __iroot__(_star2mpz($x) // (goto &nan), $y);
    }
    else {
        $r = __iroot__(_star2mpz($x) // (goto &nan), _any2si(_str2obj($y)) // (goto &nan));
    }

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iroot => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    my $r = __iroot__(_star2mpz($x) // (goto &nan), _any2si($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod iroot => qw(* *) => sub {
    require Math::AnyNum::iroot;
    my ($x, $y) = @_;
    my $r = __iroot__(_star2mpz($x) // (goto &nan), _any2si(${__PACKAGE__->new($y)}) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## ISQRTREM
#

sub isqrtrem {
    require Math::AnyNum::isqrtrem;
    my ($root, $rem) = __isqrtrem__(_star2mpz($_[0]) // (return (nan(), nan())));
    ((bless \$root, __PACKAGE__), (bless \$rem, __PACKAGE__));
}

#
## IROOTREM
#
Class::Multimethods::multimethod irootrem => qw(* $) => sub {
    require Math::AnyNum::irootrem;
    my ($x, $y) = @_;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        my ($root, $rem) = __irootrem__(_star2mpz($x) // (return (nan(), nan())), $y);
        return ((bless \$root, __PACKAGE__), (bless \$rem, __PACKAGE__));
    }
    else {
        my ($root, $rem) =
          __irootrem__(_star2mpz($x) // (return (nan(), nan())), _any2si(${__PACKAGE__->new($y)}) // (return (nan(), nan())));
        return ((bless \$root, __PACKAGE__), (bless \$rem, __PACKAGE__));
    }
};

Class::Multimethods::multimethod irootrem => qw(* *) => sub {
    require Math::AnyNum::irootrem;
    my ($x, $y) = @_;
    my ($root, $rem) =
      __irootrem__(_star2mpz($x) // (return (nan(), nan())), _any2si(${__PACKAGE__->new($y)}) // (return (nan(), nan())));
    ((bless \$root, __PACKAGE__), (bless \$rem, __PACKAGE__));
};

#
## MOD
#

Class::Multimethods::multimethod mod => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;
    my $r = __mod__(_copy($$x), $$y);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod mod => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;

    if (    ref($$x) ne 'Math::GMPq'
        and CORE::int($y) eq $y
        and $y > 0
        and $y <= ULONG_MAX) {
        my $r = __mod__(_copy($$x), $y);
        return bless \$r, __PACKAGE__;
    }

    my $r = __mod__(_copy($$x), _str2obj($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod mod => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;
    my $r = __mod__(_copy($$x), ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod mod => qw(* *) => sub {
    require Math::AnyNum::mod;
    my ($x, $y) = @_;
    my $r = __mod__(${__PACKAGE__->new($x)}, ${__PACKAGE__->new($y)});
    bless \$r, __PACKAGE__;
};

#
## IMOD
#
Class::Multimethods::multimethod imod => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::imod;
    my ($x, $y) = @_;
    my $r = __imod__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod imod => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::imod;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and CORE::abs($y) <= ULONG_MAX) {
        $r = __imod__(_copy2mpz($$x) // (goto &nan), $y);
    }
    else {
        $r = __imod__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan));
    }
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod imod => qw(* *) => sub {
    require Math::AnyNum::imod;
    my ($x, $y) = @_;
    my $r = __imod__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## DIVMOD
#

sub divmod {
    require Math::AnyNum::divmod;
    my ($x, $y) = @_;
    my ($r1, $r2) = __divmod__(_star2mpz($x) // (return (nan(), nan())), _star2mpz($y) // (return (nan(), nan())));
    ((bless \$r1, __PACKAGE__), (bless \$r2, __PACKAGE__));
}

#
## is_div
#

sub is_div {
    mod($_[0], $_[1])->is_zero;
}

#
## SPECIAL
#

sub ln {
    require Math::AnyNum::log;
    my $r = __log__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub log2 {
    require Math::AnyNum::log;
    my $r = __log2__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub log10 {
    require Math::AnyNum::log;
    my $r = __log10__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub length {
    my ($z) = _star2mpz($_[0]) // return -1;

    Math::GMPz::Rmpz_neg($z, $z)
      if Math::GMPz::Rmpz_sgn($z) < 0;

    #__PACKAGE__->_set_uint(Math::GMPz::Rmpz_snprintf(my $buf, 0, "%Zd", $z, 0));
    CORE::length(Math::GMPz::Rmpz_get_str($z, 10));
}

Class::Multimethods::multimethod log => qw(* *) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my ($x, $y) = @_;
    my $r = __div__(__log__(_star2mpfr_mpc($x)), __log__(_star2mpfr_mpc($y)));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod log => qw(*) => \&ln;

#
## ILOG
#

sub ilog2 {
    require Math::AnyNum::log;
    my $r = _any2mpz(__log2__(_star2mpfr_mpc($_[0]))) // goto &nan;
    bless \$r, __PACKAGE__;
}

sub ilog10 {
    require Math::AnyNum::log;
    my $r = _any2mpz(__log10__(_star2mpfr_mpc($_[0]))) // goto &nan;
    bless \$r, __PACKAGE__;
}

Class::Multimethods::multimethod ilog => qw(* *) => sub {
    require Math::AnyNum::log;
    require Math::AnyNum::div;
    my $r = _any2mpz(__div__(__log__(_star2mpfr_mpc($_[0])), __log__(_star2mpfr_mpc($_[1])))) // goto &nan;
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod ilog => qw(*) => sub {
    require Math::AnyNum::log;
    my $r = _any2mpz(__log__(_star2mpfr_mpc($_[0]))) // goto &nan;
    bless \$r, __PACKAGE__;
};

#
## SQRT
#

sub sqrt {
    require Math::AnyNum::sqrt;
    my $r = __sqrt__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub cbrt {
    require Math::AnyNum::cbrt;
    my $r = __cbrt__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub sqr {
    require Math::AnyNum::mul;
    my ($x) = @_;
    if (ref($x) eq __PACKAGE__) {
        my $r = _copy($$x);
        $r = __mul__($r, $r);
        bless \$r, __PACKAGE__;
    }
    else {
        my $r = __PACKAGE__->new($x);
        $$r = __mul__($$r, $$r);
        $r;
    }
}

sub exp {
    require Math::AnyNum::exp;
    my $r = __exp__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub floor {
    require Math::AnyNum::floor;
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        my $r = $$x;
        ref($r) eq 'Math::GMPz' and return $x;    # already an integer
        $r = __floor__(ref($r) eq 'Math::GMPq' ? $r : _copy($r));
        bless \$r, __PACKAGE__;
    }
    else {
        __PACKAGE__->new($x)->floor;
    }
}

sub ceil {
    require Math::AnyNum::ceil;
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        my $r = $$x;
        ref($r) eq 'Math::GMPz' and return $x;    # already an integer
        $r = __ceil__(ref($r) eq 'Math::GMPq' ? $r : _copy($r));
        bless \$r, __PACKAGE__;
    }
    else {
        __PACKAGE__->new($x)->ceil;
    }
}

#
## sin / sinh / asin / asinh
#

sub sin {
    require Math::AnyNum::sin;
    my $r = __sin__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub sinh {
    require Math::AnyNum::sinh;
    my $r = __sinh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub asin {
    require Math::AnyNum::asin;
    my $r = __asin__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub asinh {
    require Math::AnyNum::asinh;
    my $r = __asinh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## cos / cosh / acos / acosh
#

sub cos {
    require Math::AnyNum::cos;
    my $r = __cos__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub cosh {
    require Math::AnyNum::cosh;
    my $r = __cosh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acos {
    require Math::AnyNum::acos;
    my $r = __acos__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acosh {
    require Math::AnyNum::acosh;
    my $r = __acosh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## tan / tanh / atan / atanh
#

sub tan {
    require Math::AnyNum::tan;
    my $r = __tan__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub tanh {
    require Math::AnyNum::tanh;
    my $r = __tanh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub atan {
    require Math::AnyNum::atan;
    my $r = __atan__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub atanh {
    require Math::AnyNum::atanh;
    my $r = __atanh__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub atan2 {
    require Math::AnyNum::atan2;
    my ($x, $y) = @_;
    my $r = __atan2__(_star2mpfr_mpc($x), _star2mpfr_mpc($y));
    bless \$r, __PACKAGE__;
}

#
## sec / sech / asec / asech
#

sub sec {
    require Math::AnyNum::sec;
    my $r = __sec__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub sech {
    require Math::AnyNum::sech;
    my $r = __sech__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub asec {
    require Math::AnyNum::asec;
    my $r = __asec__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub asech {
    require Math::AnyNum::asech;
    my $r = __asech__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## csc / csch / acsc / acsch
#

sub csc {
    require Math::AnyNum::csc;
    my $r = __csc__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub csch {
    require Math::AnyNum::csch;
    my $r = __csch__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acsc {
    require Math::AnyNum::acsc;
    my $r = __acsc__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acsch {
    require Math::AnyNum::acsch;
    my $r = __acsch__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## cot / coth / acot / acoth
#

sub cot {
    require Math::AnyNum::cot;
    my $r = __cot__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub coth {
    require Math::AnyNum::coth;
    my $r = __coth__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acot {
    require Math::AnyNum::acot;
    my $r = __acot__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub acoth {
    require Math::AnyNum::acoth;
    my $r = __acoth__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

sub deg2rad {
    require Math::AnyNum::mul;
    my ($x) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($f, $ROUND);
    Math::MPFR::Rmpfr_div_ui($f, $f, 180, $ROUND);
    my $r = __mul__(_star2mpfr_mpc($x), $f);
    bless \$r, __PACKAGE__;
}

sub rad2deg {
    require Math::AnyNum::mul;
    my ($x) = @_;
    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPFR::Rmpfr_const_pi($f, $ROUND);
    Math::MPFR::Rmpfr_ui_div($f, 180, $f, $ROUND);
    my $r = __mul__(_star2mpfr_mpc($x), $f);
    bless \$r, __PACKAGE__;
}

#
## gamma
#

sub gamma {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_gamma($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## lgamma
#

sub lgamma {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_lgamma($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## lngamma
#

sub lngamma {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_lngamma($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## digamma
#

sub digamma {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_digamma($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## zeta
#

sub zeta {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_zeta($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## eta
#

sub eta {
    require Math::AnyNum::eta;
    my $r = __eta__(_star2mpfr($_[0]));
    bless \$r, __PACKAGE__;
}

#
## beta
#
Class::Multimethods::multimethod beta => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::beta;
    my ($x, $y) = @_;
    my $r = __beta__(_star2mpfr($x), _any2mpfr($$y));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod beta => qw(* *) => sub {
    require Math::AnyNum::beta;
    my $r = __beta__(_star2mpfr($_[0]), _star2mpfr($_[1]));
    bless \$r, __PACKAGE__;
};

#
## Airy function (Ai)
#

sub Ai {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_ai($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Exponential integral (Ei)
#

sub Ei {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_eint($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Logarithmic integral (Li)
#
sub Li {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_log($r, $r, $ROUND);
    Math::MPFR::Rmpfr_eint($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Dilogarithm function (Li_2)
#
sub Li2 {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_li2($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Error function
#
sub erf {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_erf($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Complementary error function
#
sub erfc {
    my $r = _star2mpfr($_[0]);
    Math::MPFR::Rmpfr_erfc($r, $r, $ROUND);
    bless \$r, __PACKAGE__;
}

#
## Lambert W
#

sub LambertW {
    require Math::AnyNum::LambertW;
    my $r = __LambertW__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## lgrt -- logarithmic root
#

sub lgrt {
    require Math::AnyNum::lgrt;
    my $r = __lgrt__(_star2mpfr_mpc($_[0]));
    bless \$r, __PACKAGE__;
}

#
## agm
#
sub agm {
    require Math::AnyNum::agm;
    my ($x, $y) = @_;
    my $r = __agm__(_star2mpfr($x), _star2mpfr($y));
    bless \$r, __PACKAGE__;
}

#
## hypot
#

sub hypot {
    require Math::AnyNum::hypot;
    my ($x, $y) = @_;
    my $r = __hypot__(_star2mpfr_mpc($x), _star2mpfr_mpc($y));
    bless \$r, __PACKAGE__;
}

#
## BesselJ
#

Class::Multimethods::multimethod BesselJ => qw(* $) => sub {
    require Math::AnyNum::BesselJ;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        $r = __BesselJ__(_star2mpfr($x), $y);
    }
    else {
        $r = __BesselJ__(_star2mpfr($x), _star2mpz($y) // (goto &nan));
    }

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod BesselJ => qw(* *) => sub {
    require Math::AnyNum::BesselJ;
    my ($x, $y) = @_;
    my $r = __BesselJ__(_star2mpfr($x), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## BesselY
#

Class::Multimethods::multimethod BesselY => qw(* $) => sub {
    require Math::AnyNum::BesselY;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        $r = __BesselY__(_star2mpfr($x), $y);
    }
    else {
        $r = __BesselY__(_star2mpfr($x), _star2mpz($y) // (goto &nan));
    }

    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod BesselY => qw(* *) => sub {
    require Math::AnyNum::BesselY;
    my ($x, $y) = @_;
    my $r = __BesselY__(_star2mpfr($x), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## ROUND
#

Class::Multimethods::multimethod round => qw(Math::AnyNum) => sub {
    require Math::AnyNum::round;
    my ($x) = @_;
    my $r = __round__(_copy($$x), 0);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod round => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;
    my $r = __round__(_copy($$x), _any2si($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod round => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;

    my $r;
    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        $r = __round__(_copy($$x), $y);
    }
    else {
        $r = __round__(_copy($$x), _any2si(_str2obj($y)) // (goto &nan));
    }
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod round => qw(*) => sub {
    require Math::AnyNum::round;
    my ($x) = @_;
    my $r = __round__(${__PACKAGE__->new($x)}, 0);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod round => qw(* *) => sub {
    require Math::AnyNum::round;
    my ($x, $y) = @_;
    my $r = __round__(${__PACKAGE__->new($x)}, _any2si(${__PACKAGE__->new($y)}) // (goto &nan));
    bless \$r, __PACKAGE__;
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
            $rand = __mul__($rand, __sub__(_copy($$y), $$x));
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

        sub seed {
            my $z = _star2mpz($_[0]) // do {
                require Carp;
                Carp::croak("invalid seed: <<$_[0]>> (expected an integer)");
            };
            Math::MPFR::Rmpfr_randseed($state, $z);
            bless \$z, __PACKAGE__;
        }
    }

    {
        state $state = Math::GMPz::zgmp_randinit_mt_nobless();
        Math::GMPz::zgmp_randseed_ui($state, $srand);

        Class::Multimethods::multimethod irand => qw(Math::AnyNum Math::AnyNum) => sub {
            require Math::AnyNum::irand;
            my ($x, $y) = @_;
            my $r = __irand__(_any2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan), $state);
            bless \$r, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(Math::AnyNum *) => sub {
            require Math::AnyNum::irand;
            my ($x, $y) = @_;
            my $r = __irand__(_any2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan), $state);
            bless \$r, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(* Math::AnyNum) => sub {
            require Math::AnyNum::irand;
            my ($x, $y) = @_;
            my $r = __irand__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan), $state);
            bless \$r, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(*) => sub {
            require Math::AnyNum::irand;
            my $r = __irand__(_star2mpz($_[0]) // (goto &nan), $state);
            bless \$r, __PACKAGE__;
        };

        Class::Multimethods::multimethod irand => qw(* *) => sub {
            require Math::AnyNum::irand;
            my $r = __irand__(_star2mpz($_[0]) // (goto &nan), _star2mpz($_[1]) // (goto &nan), $state);
            bless \$r, __PACKAGE__;
        };

        sub iseed {
            my $z = _star2mpz($_[0]) // do {
                require Carp;
                Carp::croak("invalid seed: <<$_[0]>> (expected an integer)");
            };
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
## harmfrac
#

sub harmfrac {
    require Math::AnyNum::harmfrac;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $q = __harmfrac__(CORE::int($x));
            return bless \$q, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->harmfrac;
    }

    my $n = _any2ui($$x) // (goto &nan);
    my $q = __harmfrac__($n);
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

    my $n = _any2ui($$x) // (goto &nan);
    my $f = __bernreal__($n);
    bless \$f, __PACKAGE__;
}

#
## harmreal
#

sub harmreal {
    require Math::AnyNum::harmreal;
    my ($x) = @_;
    my $n = _star2mpfr($x) // (goto &nan);
    my $f = __harmreal__($n);
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
## Double-factorial
#

sub dfactorial {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {    # called as a function
        if (CORE::int($x) eq $x and $x >= 0 and $x <= ULONG_MAX) {
            my $z = Math::GMPz::Rmpz_init();
            Math::GMPz::Rmpz_2fac_ui($z, CORE::int($x));
            return bless \$z, __PACKAGE__;
        }
        return __PACKAGE__->new($x)->dfactorial;
    }

    my $ui = _any2ui($$x) // (goto &nan);
    my $z = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_2fac_ui($z, $ui);
    bless \$z, __PACKAGE__;
}

#
## M-factorial
#

sub mfactorial {
    my ($x, $y) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = $$x;
    }
    else {
        $x = ${__PACKAGE__->new($x)};
    }

    if (ref($y) eq __PACKAGE__) {
        $y = $$y;
    }
    else {
        $y = ${__PACKAGE__->new($y)};
    }

    my $ui1 = _any2ui($x) // (goto &nan);
    my $ui2 = _any2ui($y) // (goto &nan);
    my $z   = Math::GMPz::Rmpz_init();
    Math::GMPz::Rmpz_mfac_uiui($z, $ui1, $ui2);
    bless \$z, __PACKAGE__;
}

#
## GCD
#

Class::Multimethods::multimethod gcd => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::gcd;
    my ($x, $y) = @_;
    my $r = __gcd__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod gcd => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::gcd;
    my ($x, $y) = @_;
    my $r = __gcd__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod gcd => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::gcd;
    my ($x, $y) = @_;
    my $r = __gcd__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod gcd => qw(* *) => sub {
    require Math::AnyNum::gcd;
    my ($x, $y) = @_;
    my $r = __gcd__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## LCM
#

Class::Multimethods::multimethod lcm => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::lcm;
    my ($x, $y) = @_;
    my $r = __lcm__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod lcm => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::lcm;
    my ($x, $y) = @_;
    my $r = __lcm__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod lcm => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::lcm;
    my ($x, $y) = @_;
    my $r = __lcm__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod lcm => qw(* *) => sub {
    require Math::AnyNum::lcm;
    my $r = __lcm__(_star2mpz($_[0]) // (goto &nan), _star2mpz($_[1]) // (goto &nan));
    bless \$r, __PACKAGE__;
};

#
## next_prime
#

sub next_prime {
    my $r = _star2mpz($_[0]) // (goto &nan);
    Math::GMPz::Rmpz_nextprime($r, $r);
    bless \$r, __PACKAGE__;
}

#
## is_prime
#

sub is_prime {
    my ($x, $y) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    $x->is_int() || return 0;
    $y = defined($y) ? (CORE::abs(CORE::int($y)) || 20) : 20;

    Math::GMPz::Rmpz_probab_prime_p(_any2mpz($$x) // (return 0), $y);
}

sub is_int {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    $ref eq 'Math::GMPz' && return 1;
    $ref eq 'Math::GMPq' && return Math::GMPq::Rmpq_integer_p($r);
    $ref eq 'Math::MPFR' && return Math::MPFR::Rmpfr_integer_p($r);

    (@_) = _any2mpfr($r);
    goto &is_int;
}

sub is_rat {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    ($ref eq 'Math::GMPz' or $ref eq 'Math::GMPq')
      ? 1
      : 0;
}

sub numerator {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    ref($r) eq 'Math::GMPz' && return $x;    # is an integer

    if (ref($r) eq 'Math::GMPq') {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPq::Rmpq_get_num($z, $r);
        return bless \$z, __PACKAGE__;
    }

    (@_) = _any2mpq($r) // (goto &nan);
    goto &numerator;
}

sub denominator {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    ref($r) eq 'Math::GMPz' && (goto &one);    # is an integer

    if (ref($r) eq 'Math::GMPq') {
        my $z = Math::GMPz::Rmpz_init();
        Math::GMPq::Rmpq_get_den($z, $r);
        return bless \$z, __PACKAGE__;
    }

    (@_) = _any2mpq($r) // (goto &nan);
    goto &denominator;
}

sub as_frac {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $num = $x->numerator;
    my $den = $x->denominator;

    "$num/$den";
}

sub sgn {
    require Math::AnyNum::sgn;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r = __sgn__($$x);
    ref($r) ? (bless \$r, __PACKAGE__) : $r;
}

sub is_real {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    $ref eq 'Math::GMPz' && return 1;
    $ref eq 'Math::GMPq' && return 1;
    $ref eq 'Math::MPFR' && return Math::MPFR::Rmpfr_number_p($r);

    (@_) = _any2mpfr($r);
    goto &is_real;
}

sub is_imag {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r = $$x;
    ref($r) eq 'Math::MPC' or return 0;

    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::RMPC_RE($f, $r);
    Math::MPFR::Rmpfr_zero_p($f) || return 0;    # is complex
    Math::MPC::RMPC_IM($f, $r);
    !Math::MPFR::Rmpfr_zero_p($f);
}

sub is_complex {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r = $$x;
    ref($r) eq 'Math::MPC' or return 0;

    my $f = Math::MPFR::Rmpfr_init2($PREC);
    Math::MPC::RMPC_IM($f, $r);
    Math::MPFR::Rmpfr_zero_p($f) && return 0;    # is real
    Math::MPC::RMPC_RE($f, $r);
    !Math::MPFR::Rmpfr_zero_p($f);
}

sub is_inf {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    $ref eq 'Math::GMPz' && return 0;
    $ref eq 'Math::GMPq' && return 0;
    $ref eq 'Math::MPFR' && return (Math::MPFR::Rmpfr_inf_p($r) and Math::MPFR::Rmpfr_sgn_p($r) > 0);

    (@_) = _any2mpfr($r);
    goto &is_inf;
}

sub is_ninf {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    $ref eq 'Math::GMPz' && return 0;
    $ref eq 'Math::GMPq' && return 0;
    $ref eq 'Math::MPFR' && return (Math::MPFR::Rmpfr_inf_p($r) and Math::MPFR::Rmpfr_sgn_p($r) < 0);

    (@_) = _any2mpfr($r);
    goto &is_ninf;
}

sub is_nan {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $r   = $$x;
    my $ref = ref($r);

    $ref eq 'Math::GMPz' && return 0;
    $ref eq 'Math::GMPq' && return 0;
    $ref eq 'Math::MPFR' && return Math::MPFR::Rmpfr_nan_p($r);

    my $real = Math::MPFR::Rmpfr_init2($PREC);
    my $imag = Math::MPFR::Rmpfr_init2($PREC);

    Math::MPC::RMPC_RE($real, $r);
    Math::MPC::RMPC_IM($imag, $r);

    if (   Math::MPFR::Rmpfr_nan_p($real)
        or Math::MPFR::Rmpfr_nan_p($imag)) {
        return 1;
    }

    return 0;
}

sub is_even {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    $x->is_int()
      && Math::GMPz::Rmpz_even_p(_any2mpz($$x) // (return 0));
}

sub is_odd {
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    $x->is_int()
      && Math::GMPz::Rmpz_odd_p(_any2mpz($$x) // (return 0));
}

sub is_zero {
    require Math::AnyNum::cmp;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    (__cmp__($$x, 0) // return undef) == 0;
}

sub is_one {
    require Math::AnyNum::cmp;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    (__cmp__($$x, 1) // return undef) == 0;
}

sub is_mone {
    require Math::AnyNum::cmp;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    (__cmp__($$x, -1) // return undef) == 0;
}

sub is_pos {
    require Math::AnyNum::cmp;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    (__cmp__($$x, 0) // return undef) > 0;
}

sub is_neg {
    require Math::AnyNum::cmp;
    my ($x) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    (__cmp__($$x, 0) // return undef) < 0;
}

#
## is_square
#
sub is_square {
    my ($x, $y) = @_;

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    $x->is_int()
      and Math::GMPz::Rmpz_perfect_square_p(_any2mpz($$x) // (return 0));
}

#
## is_power
#

Class::Multimethods::multimethod is_power => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::is_power;
    my ($x, $y) = @_;
    $x->is_int()
      and __is_power__(_any2mpz($$x) // (return 0), _any2si($$y) // (return 0));
};

Class::Multimethods::multimethod is_power => qw(Math::AnyNum $) => sub {
    require Math::AnyNum::is_power;
    my ($x, $y) = @_;

    $x->is_int() || return 0;
    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        __is_power__(_star2mpz($x) // (return 0), $y);
    }
    else {
        __is_power__(_any2mpz($$x) // (return 0), _any2si(${__PACKAGE__->new($y)}) // (return 0));
    }
};

Class::Multimethods::multimethod is_power => qw(* $) => sub {
    require Math::AnyNum::is_power;
    my ($x, $y) = @_;

    $x = __PACKAGE__->new($x);
    $x->is_int() || return 0;

    if (CORE::int($y) eq $y and $y <= ULONG_MAX and $y >= LONG_MIN) {
        __is_power__(_any2mpz($$x) // (return 0), $y);
    }
    else {
        __is_power__(_any2mpz($$x) // (return 0), _any2si(${__PACKAGE__->new($y)}) // (return 0));
    }
};

Class::Multimethods::multimethod is_power => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::is_power;
    my ($x, $y) = @_;
    $x = __PACKAGE__->new($x);
    $x->is_int()
      and __is_power__(_any2mpz($$x) // (return 0), _any2si($$y) // (return 0));
};

Class::Multimethods::multimethod is_power => qw(* *) => sub {
    require Math::AnyNum::is_power;
    my ($x, $y) = @_;
    $x = __PACKAGE__->new($x);
    $x->is_int()
      and __is_power__(_any2mpz($$x) // (return 0), _any2si(${__PACKAGE__->new($y)}) // (return 0));
};

Class::Multimethods::multimethod is_power => qw(Math::AnyNum) => sub {
    my ($x) = @_;
    $x->is_int()
      and Math::GMPz::Rmpz_perfect_power_p(_any2mpz($$x) // (return 0));
};

Class::Multimethods::multimethod is_power => qw(*) => sub {
    my ($x) = @_;
    $x = __PACKAGE__->new($x);
    $x->is_int()
      and Math::GMPz::Rmpz_perfect_power_p(_any2mpz($$x) // (return 0));
};

#
## kronecker
#

Class::Multimethods::multimethod kronecker => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_kronecker(_any2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
};

Class::Multimethods::multimethod kronecker => qw(Math::AnyNum *) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_kronecker(_any2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan));
};

Class::Multimethods::multimethod kronecker => qw(* Math::AnyNum) => sub {
    my ($x, $y) = @_;
    Math::GMPz::Rmpz_kronecker(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan));
};

Class::Multimethods::multimethod kronecker => qw(* *) => sub {
    Math::GMPz::Rmpz_kronecker(_star2mpz($_[0]) // (goto &nan), _star2mpz($_[1]) // (goto &nan));
};

#
## valuation
#

Class::Multimethods::multimethod valuation => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    __valuation__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan));
};

Class::Multimethods::multimethod valuation => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    __valuation__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan));
};

Class::Multimethods::multimethod valuation => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    __valuation__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan));
};

Class::Multimethods::multimethod valuation => qw(* *) => sub {
    require Math::AnyNum::valuation;
    __valuation__(_star2mpz($_[0]) // (goto &nan), _star2mpz($_[1]) // (goto &nan));
};

#
## remdiv
#

Class::Multimethods::multimethod remdiv => qw(Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    my $r = _copy2mpz($$x) // (goto &nan);
    __valuation__($r, _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod remdiv => qw(Math::AnyNum *) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    my $r = _copy2mpz($$x) // (goto &nan);
    __valuation__($r, _star2mpz($y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod remdiv => qw(* Math::AnyNum) => sub {
    require Math::AnyNum::valuation;
    my ($x, $y) = @_;
    my $r = _star2mpz($x) // (goto &nan);
    __valuation__($r, _any2mpz($$y) // (goto &nan));
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod remdiv => qw(* *) => sub {
    require Math::AnyNum::valuation;
    my $r = _star2mpz($_[0]) // (goto &nan);
    __valuation__($r, _star2mpz($_[1]) // (goto &nan));
    bless \$r, __PACKAGE__;
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
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan), _any2mpz($$z) // (goto &nan))
      // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum * Math::AnyNum) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan), _any2mpz($$z) // (goto &nan))
      // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum Math::AnyNum *) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_copy2mpz($$x) // (goto &nan), _any2mpz($$y) // (goto &nan), _star2mpz($z) // (goto &nan))
      // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(Math::AnyNum * *) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_copy2mpz($$x) // (goto &nan), _star2mpz($y) // (goto &nan), _star2mpz($z) // (goto &nan))
      // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(* Math::AnyNum *) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan), _star2mpz($z) // (goto &nan)) // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(* Math::AnyNum Math::AnyNum) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_star2mpz($x) // (goto &nan), _any2mpz($$y) // (goto &nan), _any2mpz($$z) // (goto &nan)) // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(* * Math::AnyNum) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan), _any2mpz($$z) // (goto &nan)) // goto(&nan);
    bless \$r, __PACKAGE__;
};

Class::Multimethods::multimethod powmod => qw(* * *) => sub {
    require Math::AnyNum::powmod;
    my ($x, $y, $z) = @_;
    my $r = __powmod__(_star2mpz($x) // (goto &nan), _star2mpz($y) // (goto &nan), _star2mpz($z) // (goto &nan)) // goto(&nan);
    bless \$r, __PACKAGE__;
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

    my $z = _copy2mpz($$x) // (goto &nan);
    my $n = _any2mpz($$y)  // (goto &nan);

    Math::GMPz::Rmpz_and($z, $z, $n);

    bless \$z, __PACKAGE__;
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

    my $z = _copy2mpz($$x) // (goto &nan);
    my $n = _any2mpz($$y)  // (goto &nan);

    Math::GMPz::Rmpz_ior($z, $z, $n);

    bless \$z, __PACKAGE__;
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

    my $z = _copy2mpz($$x) // (goto &nan);
    my $n = _any2mpz($$y)  // (goto &nan);

    Math::GMPz::Rmpz_xor($z, $z, $n);

    bless \$z, __PACKAGE__;
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
    my $z = _copy2mpz($$x) // (goto &nan);
    Math::GMPz::Rmpz_com($z, $z);
    bless \$z, __PACKAGE__;
}

#
## LEFT SHIFT
#

Class::Multimethods::multimethod lsft => qw(Math::AnyNum Math::AnyNum) => sub {
    my ($x, $y) = @_;

    my $n = _any2si($$y)   // (goto &nan);
    my $z = _copy2mpz($$x) // (goto &nan);

    $n < 0
      ? Math::GMPz::Rmpz_div_2exp($z, $z, -$n)
      : Math::GMPz::Rmpz_mul_2exp($z, $z, $n);

    bless \$z, __PACKAGE__;
};

Class::Multimethods::multimethod lsft => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _copy2mpz($$x) // (goto &nan);

        $y < 0
          ? Math::GMPz::Rmpz_div_2exp($z, $z, -$y)
          : Math::GMPz::Rmpz_mul_2exp($z, $z, $y);

        bless \$z, __PACKAGE__;
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

    my $n = _any2si($$y)   // (goto &nan);
    my $z = _copy2mpz($$x) // (goto &nan);

    $n < 0
      ? Math::GMPz::Rmpz_mul_2exp($z, $z, -$n)
      : Math::GMPz::Rmpz_div_2exp($z, $z, $n);

    bless \$z, __PACKAGE__;
};

Class::Multimethods::multimethod rsft => qw(Math::AnyNum $) => sub {
    my ($x, $y) = @_;

    if (CORE::int($y) eq $y and $y >= LONG_MIN and $y <= ULONG_MAX) {
        my $z = _copy2mpz($$x) // (goto &nan);

        $y < 0
          ? Math::GMPz::Rmpz_mul_2exp($z, $z, -$y)
          : Math::GMPz::Rmpz_div_2exp($z, $z, $y);

        bless \$z, __PACKAGE__;
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

    if (ref($x) ne __PACKAGE__) {
        $x = __PACKAGE__->new($x);
    }

    my $z = _any2mpz($$x) // return -1;
    if (Math::GMPz::Rmpz_sgn($z) < 0) {
        my $t = Math::GMPz::Rmpz_init();
        Math::GMPz::Rmpz_neg($t, $z);
        $z = $t;
    }
    Math::GMPz::Rmpz_popcount($z);
}

#
## Conversions
#

sub as_bin {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = _any2mpz($$x) // return undef;
    }
    else {
        $x = _star2mpz($x) // return undef;
    }

    Math::GMPz::Rmpz_get_str($x, 2);
}

sub as_oct {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = _any2mpz($$x) // return undef;
    }
    else {
        $x = _star2mpz($x) // return undef;
    }

    Math::GMPz::Rmpz_get_str($x, 8);
}

sub as_hex {
    my ($x) = @_;

    if (ref($x) eq __PACKAGE__) {
        $x = _any2mpz($$x) // return undef;
    }
    else {
        $x = _star2mpz($x) // return undef;
    }

    Math::GMPz::Rmpz_get_str($x, 16);
}

sub as_int {
    my ($x, $y) = @_;

    my $base = 10;
    if (defined($y)) {

        if (ref($y) eq '' and CORE::int($y) eq $y) {
            $base = $y;
        }
        elsif (ref($y) eq __PACKAGE__) {
            $base = _any2ui($$y) // 0;
        }
        else {
            $base = _any2ui(${__PACKAGE__->new($y)}) // 0;
        }

        if ($base < 2 or $base > 36) {
            require Carp;
            Carp::croak("base must be between 2 and 36, got $y");
        }
    }

    if (ref($x) eq __PACKAGE__) {
        $x = _any2mpz($$x) // return undef;
    }
    else {
        $x = _star2mpz($x) // return undef;
    }

    Math::GMPz::Rmpz_get_str($x, $base);
}

sub digits {
    my ($x, $y) = @_;
    my $str = as_int($x, $y) // return ();
    my @digits = split(//, $str);
    shift(@digits) if $digits[0] eq '-';
    (@digits);
}

1;    # End of Math::AnyNum
