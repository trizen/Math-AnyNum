#!/usr/bin/perl

#
## http://rosettacode.org/wiki/Arithmetic-geometric_mean/Calculate_Pi#Perl
#

use 5.016;
use strict;
use warnings;

use lib qw(../lib);
use Math::AnyNum qw(rand floor ilog log beta round irand pow);

my @arr = (1, 2, 3, 4);
say rand(23);
say rand(@arr);
say rand(100, 150);

$_ = 42.5;

say rand(100, 150);

say log;
say log(Math::AnyNum->new(13), Math::AnyNum->new(3));
say log(15);

use Math::BigInt;
my $x = Math::AnyNum->new(13);
my $y = Math::BigInt->new(15);

say "beta($x, $y)";

say beta($x, $y);
say beta(13, $y);
say beta($x, 15);

say round(123.4123,                    Math::AnyNum->new(-2));
say round(Math::AnyNum->new(123.4123), Math::AnyNum->new(-2));
say round(Math::AnyNum->new(123.4123), -2);

say rand(1000, 1100);
say irand(1000, 1100);
say rand(1100);
say irand(-5, 5);
say irand(1000);

say ref ${pow("1/2", 98126381263821372)}
