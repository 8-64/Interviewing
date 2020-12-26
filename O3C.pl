#!/usr/bin/perl

use v5.24;
use warnings;

use Test::More;
use experimental 'signatures';

=encoding UTF-8

=head1 Power of 2

Function is supplied with a number (positive int). Detect whether this number is
a power of 2

=head1 Missing number

Function is supplied with a list of numbers (ex, [5,3,2,4]).
List of numbers is expected to increase by 1 sequentually, starting from 1.
Detect, whether there is a number missing.

=cut

# Power of 2
# One of the ways to detect it - binary & of n and n - 1 should be 0
#   Other methods:
#   - in cycle detect whether the number equals to a power of 2
#   - power of 2 should have only one "1" in a binary representation
#   - log(n)/log(2) should be integer, ex. log(8)/log(2) == 3
sub is_power_of_2 ($n) {
    return ! ($n & ($n - 1));
}

# Missing number
# Sort the array, then compare the last number with the number of entries in
# the array. Complexity is around O(log n)
sub is_number_missing (@numbers) {
    @numbers = sort { $a <=> $b } @numbers;
    return 0 if ($numbers[-1] == @numbers);
    return 1;
}

ok((
    is_power_of_2(2)
and is_power_of_2(8)
and is_power_of_2(1024)
and is_power_of_2(1)
and ! is_power_of_2(5)
and ! is_power_of_2(1025)
    ), 'Power of 2 is detected as expected');

ok((
    ! is_number_missing(1)
and ! is_number_missing(1..200)
and ! is_number_missing(5,4,2,3,1)
and is_number_missing(6,4,2,3,1)
and is_number_missing(10,9)
and is_number_missing(1025)
    ), 'Detected when the number is missing');

done_testing();
