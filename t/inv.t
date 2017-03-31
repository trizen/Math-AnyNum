#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 4;

use Math::AnyNum;

my $q = Math::AnyNum->new_q('3/4');
$q->inv;
is($q, '4/3');

my $f = Math::AnyNum->new_f('5');
$f->inv;
is($f, '0.2');

my $z = Math::AnyNum->new_z('41');
$z->inv;
is($z, '1/41');

my $c = Math::AnyNum->new_c('3', '4');
$c->inv;
is($c, '0.12-0.16i');
