#!/usr/bin/perl

use v5.26;
use warnings;
use experimental 'signatures';

sub maxGuests ($log) {
    my $guests = 0;
    my @max_guests = (0, 0);

    my %entries = ();
    foreach (@$log) {
        $entries{ $_->[0] }++;
        $entries{ $_->[1] }--;
    }

    foreach my $time (sort { $a <=> $b } keys %entries) {
        $guests += $entries{$time};
        @max_guests = ($guests, $time) if ($guests > $max_guests[0]);
    }

    return "Max $max_guests[0] guests at time $max_guests[1]";
}

my $log = [
    [ 10, 20],
    [ 11, 20],
    [ 12, 30],
    [ 10, 15],
    [ 11, 20],
];

say maxGuests($log);

__END__

=pod

=item1 TASK DESCRIPTION

    Consider a big party where a log register for guest’s entry and exit times is maintained.
    Find the time at which there are maximum guests in the party.
    Note that entries in register are not in any order.

=cut
