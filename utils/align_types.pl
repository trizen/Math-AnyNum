#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

# Align the return types to be on the same column.
# usage: perl align_types.pl < old.pm > new.pm

while (<>) {
    if (/^(\h++.+?)(#=> .*)/) {
        my $before = unpack('A*', $1);
        my $after = $2;
        say $before . ' ' x (50 - length($before)) . $after;
    }
    else {
        print $_;
    }
}
