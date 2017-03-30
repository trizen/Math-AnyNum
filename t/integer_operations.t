#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 67;

use Math::AnyNum;

{
    my $z = Math::AnyNum->new_z('43');

    is($z->popcount, 4);
    is($z,           43);
    $z->neg;
    is($z,           -43);
    is($z->popcount, 4);
    is($z,           -43);

    my $c = Math::AnyNum->new_c('3', '4');
    is($c->popcount, -1);        # complex cannot be converted to an integer
    is($c,           '3+4i');    # make sure the object is intact
}

{
    my $z  = Math::AnyNum->new_z('12');
    my $t1 = $z->factorial;
    is($t1, '479001600');
    is($z,  '12');               # make sure factorial didn't change $z
    $z = $t1;

    $z->isqrt;
    is($z, 21886);

    $z->ipow(30);
    is($z,
'16032152917429066747418982495813383711705136304907234176407498567267316572349793360954753660521310614994729887678856029514210738176'
      );

    #~ $z->ilog(21886);
    #~ is($z, '30');

    $z->log(21886);
    is($z, '30');

    $z->mul(10);
    is($z, '300');

    $z->iroot(3);
    is($z, '6');

    my $t2 = $z->binomial(3);
    is($t2, '20');
    is($z,  '6');    # make sure binomial didn't change $z
    $z = $t2;

    $z->imod(12);
    is($z, '8');
}

{
    my $n = Math::AnyNum->new('-13');
    my $y = Math::AnyNum->new('9');
    my $f = Math::AnyNum->new('5.7');

    {
        # Special
        my $z = $n->copy;
        $z->isqrt;
        is($z, 'NaN');
    }

    {
        my $z = $n->copy;
        $z->iroot(3);
        is($z, '-2');
    }

    {
        my $z = $n->copy;
        $z->iroot(-3);
        is($z, 'NaN');
    }

    {
        my $z = $n->copy;
        $z->ipow('3.95');    # gets truncated to '3'
        is($z, '-2197');
    }

    {
        my $z = $n->copy;
        $z->ipow('-3.95');    # gets truncated to '-3'
        is($z, '0');
    }

    {
        my $z = $n->copy;
        $z->ipow('4.95');     # gets truncated to '4'
        is($z, '28561');
    }

    {
        my $z = $n->copy;
        $z->ipow('-4.95');    # gets truncated to '-4'
        is($z, '0');
    }

    {
        my $z = $n->copy;
        $z->imod('-0.01');    # gets truncated to '0'
        is($z, 'NaN');
    }

    {
        my $z = $n->copy;
        $z->imod(Math::AnyNum->new('-0.91'));    # gets truncated to '0'
        is($z, 'NaN');
    }

    {
        my $z = $n->copy;
        $z->imod(Math::AnyNum->new('9.2'));      # gets truncated to '9'
        is($z, '5');
    }

    {
        my $z = $n->copy;
        $z->imod(Math::AnyNum->new('-9.9'));     # gets truncated to '9'
        is($z, '-4');
    }

    {
        my $z = $n->copy;
        $z->imod(Math::AnyNum->new('-20/2'));
        is($z, '-3');
    }

    {
        my $z = $n->copy;
        $z->imod('13');
        is($z, '0');
    }

    {
        my $z = $n->copy;
        $z->imod('-13');
        is($z, '0');
    }

    {
        my $z = $n->copy;
        $z->imod('11');
        is($z, '9');
    }

    {
        my $z = $n->copy;
        $z->imod($y);
        is($z, '5');
    }

    {
        my $z = $n->copy;
        $z->mod('11');
        is($z, '9');
    }

    {
        my $z = $n->copy;
        $z->imod('-11');
        is($z, '-2');
    }

    {
        my $z = $n->copy;
        $z->idiv('2');
        is($z, '-6');
    }

    {
        my $z = $n->copy;
        $z->idiv('-2');
        is($z, '6');
    }

    {
        my $z = $n->copy;
        $z->idiv($y);
        is($z, '-1');
    }

    {
        my $z = $n->copy;
        $z->idiv(-$y);
        is($z, '1');
    }

    {
        my $z = $n->copy;
        $z->idiv($f);
        is($z, '-2');
    }

    {
        my $z = $n->copy;
        $z->abs;
        $z->idiv($f);
        is($z, '2');
    }
}

{
    # Import functions
    use Math::AnyNum qw(
      lucas
      factorial
      fibonacci
      binomial
      primorial
      );

    is(lucas(-1),                      'NaN');
    is(lucas(0),                       '2');
    is(lucas(1),                       '1');
    is(lucas(15),                      '1364');
    is(lucas(Math::AnyNum->new('15')), '1364');
    is(lucas(Math::AnyNum->new('-4')), 'NaN');

    is(primorial(15),                      '30030');
    is(primorial(-5),                      'NaN');
    is(primorial(Math::AnyNum->new('15')), '30030');
    is(primorial(Math::AnyNum->new('-6')), 'NaN');

    is(factorial(0),                    '1');
    is(factorial(5),                    '120');
    is(factorial(-1),                   'NaN');
    is(factorial(Math::AnyNum->new(5)), '120');

    is(fibonacci(0),                     '0');
    is(fibonacci(12),                    '144');
    is(fibonacci(-3),                    'NaN');
    is(fibonacci(Math::AnyNum->new(12)), '144');

    is(binomial(12,   5),  '792');
    is(binomial(0,    0),  '1');
    is(binomial(-15,  12), '9657700');
    is(binomial(124,  -2), '0');
    is(binomial(-124, -3), '0');

    is(binomial(Math::AnyNum->new(12),  5),                     '792');
    is(binomial(-15,                    Math::AnyNum->new(12)), '9657700');
    is(binomial(Math::AnyNum->new(124), Math::AnyNum->new(-2)), '0');
}
