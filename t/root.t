#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 86;

use Math::AnyNum;

# 2 ** 240 =
# 1766847064778384329583297500742918515827483896875618958121606201292619776

test_root('2', '240', 8,  qr/^1073741824\z/);
test_root('2', '240', 9,  qr/^106528681.309990/);
test_root('2', '120', 9,  qr/^10321.273240738/);
test_root('2', '120', 17, qr/^133.32684936327/);

test_root('2', '120', 8,  qr/^32768\z/);
test_root('2', '60',  8,  qr/^181.01933598375616624/);
test_root('2', '60',  9,  qr/^101.59366732596476638/);
test_root('2', '60',  17, qr/^11.546724616239651532/);

sub test_root {
    my ($x, $n, $y, $expected) = @_;

    # Test "pow(AnyNum, Scalar)" and "root(AnyNum, Scalar)"
    my $froot = Math::AnyNum->new($x)->pow($n)->root($y);

    like($froot, $expected, "Try: Math::AnyNum->new($x)->pow($n)->root($y) == $expected");

    # Test "pow(AnyNum, Scalar)" and "root(AnyNum, Scalar)"
    like(Math::AnyNum->new($x)->pow($n)->root($y), $expected, "Try: Math::AnyNum->new($x)->pow($n)->root($y) == $expected");

    # Test "pow(AnyNum, AnyNum)" and "root(AnyNum, AnyNum)"
    like(Math::AnyNum->new($x)->pow(Math::AnyNum->new($n))->root(Math::AnyNum->new($y)), $expected);

    $expected = "$froot";
    $expected =~ s/\..*//;
    $expected = qr/$expected/;

    # Test "pow" and "iroot"
    like(Math::AnyNum->new($x)->pow($n)->iroot($y),
         $expected, "Math::AnyNum->new($x)->pow($n)->iroot($y) == $expected");
}

is(Math::AnyNum->new(-1234)->iroot(3),                    -10);
is(Math::AnyNum->new(-1234)->iroot(Math::AnyNum->new(3)), -10);

is(Math::AnyNum->new(-1234)->iroot(4),                    Math::AnyNum->nan);
is(Math::AnyNum->new(-1234)->iroot(Math::AnyNum->new(4)), Math::AnyNum->nan);

{
    my $n = Math::AnyNum->new(-1234);

    my $x = $n->copy->iroot(3);
    is($x, -10);

    $x = $n->copy->iroot(Math::AnyNum->new(3));
    is($x, -10);

    $x = $n->copy->iroot(4);
    is($x, Math::AnyNum->nan);

    $x = $n->copy->iroot(Math::AnyNum->new(4));
    is($x, Math::AnyNum->nan);
}

#########################################
# More tests

my $one  = Math::AnyNum->one;
my $mone = Math::AnyNum->mone;
my $zero = Math::AnyNum->zero;

my $inf  = Math::AnyNum->inf;
my $ninf = Math::AnyNum->ninf;
my $nan  = Math::AnyNum->nan;

# [i]root(AnyNum)
is($one->copy->root($mone),  $one);
is($one->copy->iroot($mone), $one);

is($zero->copy->root($zero),  $zero);
is($zero->copy->iroot($zero), $zero);

is($zero->copy->root($mone),  $inf);
is($zero->copy->iroot($mone), $inf);

is($mone->copy->root($zero),  $one);
is($mone->copy->iroot($zero), $one);

is($mone->copy->root($one),  $mone);
is($mone->copy->iroot($one), $mone);

my $two  = $one + $one;
my $mtwo = -$two;

is($mone->copy->root($two),  Math::AnyNum->i);
is($mone->copy->iroot($two), $nan);

is($one->copy->root($mtwo),  $one);
is($one->copy->iroot($mtwo), $one);

is($mone->copy->root($mtwo),  -(Math::AnyNum->i));
is($mone->copy->iroot($mtwo), $nan);

like($mtwo->copy->root($mtwo), qr/^-0\.70710678118654752\d*i\z/);
is($mtwo->copy->iroot($mtwo), $nan);

is($zero->copy->root($mone),  $inf);
is($zero->copy->iroot($mone), $inf);

is($two->copy->root($mone), $one / $two);

is($two->copy->iroot($mone), $zero);
is($two->copy->iroot($mtwo), $zero);

# [i]root(Scalar)
is($one->copy->root(-1),  $one);
is($one->copy->iroot(-1), $one);

is($zero->copy->root(0),  $zero);
is($zero->copy->iroot(0), $zero);

is($zero->copy->root(-1),  $inf);
is($zero->copy->iroot(-1), $inf);

is($mone->copy->root(0),  $one);
is($mone->copy->iroot(0), $one);

is($mone->copy->root(1),  $mone);
is($mone->copy->iroot(1), $mone);

is($mone->copy->root(2),  'i');
is($mone->copy->iroot(2), $nan);

is($one->copy->root(-2),  $one);
is($one->copy->iroot(-2), $one);

is($mone->copy->root(-2),  -(Math::AnyNum->i));
is($mone->copy->iroot(-2), $nan);

like($mtwo->copy->root(-2), qr/^-0\.707106781186547524\d*i\z/);
is($mtwo->copy->iroot(-2), $nan);

is($zero->copy->root(-1),  $inf);
is($zero->copy->iroot(-1), $inf);

is($two->copy->root(-1), $one / $two);

is($two->copy->iroot(-1), $zero);
is($two->copy->iroot(-2), $zero);

warn "\n\n\t\tTEST DONE: root()\n\n";

__END__

#########################################
# isqrtrem() / irootrem()

{
    my $n = Math::AnyNum->new('562891172629241178357647834151');

    my ($x, $y, $r, $c);

    ## isqrtrem(n)
    ($x, $y) = $n->isqrtrem;
    $r = $n->isqrt;

    is($x, $r);
    is($y, $n->isub($r->ipow(2)));

    ## irootrem(n, 3)
    ($x, $y) = $n->irootrem(3);
    $r = $n->iroot(3);

    is($x, $r);
    is($y, $n->isub($r->ipow(3)));

    ## irootrem(n, 10)
    ($x, $y) = $n->irootrem(10);
    $r = $n->iroot(10);

    is($x, $r);
    is($y, $n->isub($r->ipow(10)));

    ## irootrem(n, Math::AnyNum->new(4))
    $c = Math::AnyNum->new(4);
    ($x, $y) = $n->irootrem($c);
    $r = $n->iroot($c);

    is($x, $r);
    is($y, $n->isub($r->ipow($c)));

    ## irootrem(n, -3)
    $c = Math::AnyNum->new(-3);
    ($x, $y) = $n->irootrem($c);
    $r = $n->iroot($c);

    is($x, $r);
    is($y, $n->isub($r->ipow($c)));

    ## isqrtrem(n) == irootrem(n, 2)
    is(join(' ', $n->isqrtrem),    join(' ', $n->irootrem(2)));
    is(join(' ', $mone->isqrtrem), join(' ', $mone->irootrem(2)));
    is(join(' ', $zero->isqrtrem), join(' ', $zero->irootrem(2)));
    is(join(' ', $one->isqrtrem),  join(' ', $one->irootrem(2)));
    is(join(' ', $inf->isqrtrem),  join(' ', $inf->irootrem(2)));
    is(join(' ', $ninf->isqrtrem), join(' ', $ninf->irootrem(2)));

    ## isqrtrem(n) == irootrem(n, Math::AnyNum->new(2))
    my $two = Math::AnyNum->new(2);
    is(join(' ', $n->isqrtrem),    join(' ', $n->irootrem($two)));
    is(join(' ', $mone->isqrtrem), join(' ', $mone->irootrem($two)));
    is(join(' ', $zero->isqrtrem), join(' ', $zero->irootrem($two)));
    is(join(' ', $one->isqrtrem),  join(' ', $one->irootrem($two)));
    is(join(' ', $inf->isqrtrem),  join(' ', $inf->irootrem($two)));
    is(join(' ', $ninf->isqrtrem), join(' ', $ninf->irootrem($two)));

    # More tests to cover some special cases.
    # However, some of them fail under old versions of GMP < 5.1.0.
    # http://www.cpantesters.org/cpan/report/b91fc046-cfbd-11e6-a04a-a8c1413d0b36
    foreach my $k (-3 .. 3) {
        foreach my $j (-3 .. 3) {

            my $n = Math::AnyNum->new_int($k);

            # irootrem(AnyNum, Scalar)
            {
                my ($x, $y) = $n->irootrem($j);
                my $r = $n->iroot($j);
                is($x, $r, "tested ($k, $j)");

                #is($y, $n->isub($r->bipow($j)), "tested ($k, $j)");       # fails in some cases
            }

            # irootrem(AnyNum, AnyNum)
            {
                my $c = Math::AnyNum->new_int($j);
                my ($x, $y) = $n->irootrem($c);
                my $r = $n->iroot($c);
                is($x, $r, "tested ($k, $j)");

                #is($y, $n->isub($r->bipow($c)), "tested ($k, $j)");       # fails in some cases
            }
        }
    }
}
