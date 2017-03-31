#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 4;

use Math::AnyNum;

my $q = Math::AnyNum->new_q('3/4');
$q->exp;
like($q, qr/^2\.1170000166126746685453698198\d*\z/);

my $f = Math::AnyNum->new_f('-5.12');
$f->exp;
like($f, qr/^0\.0059760228950059434082326\d*\z/);

my $z = Math::AnyNum->new_z('12');
$z->exp;
like($z, qr/^162754\.7914190039208080052048\d*\z/);

my $c = Math::AnyNum->new_c('3', '4');
$c->exp;
like($c, qr/^-13\.128783081462158080327555145\d*-15\.20078446306795456220348102334\d*i\z/);
