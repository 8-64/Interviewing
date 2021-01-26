#!/usr/bin/perl

use v5.26;
use warnings;
use experimental 'signatures';

use List::Util 'max', 'min';

sub maxGuests ($log) {
    my $guests = 0;
    my @max_guests = (0, 0);

    # Create a hash with time of entry (keys -> time, values -> number of guests)
    # Create a hash with time of leaves (keys -> time, values -> number of guests)
    my %entry_times = ();
    my %leave_times = ();
    foreach (@$log) {
        $entry_times{ $_->[0] }++;
        $leave_times{ $_->[1] }++;
    }

    # Calculate max/min time for both hashes
    my $max_time = max (keys %entry_times, keys %leave_times);
    my $min_time = min (keys %entry_times, keys %leave_times);

    # for each time
        # next if does not exist key in both of those hash maps
        # if there are guests arriving -> increment guests counter
        # if there are guests leaving -> decrement guests counter
        # if there n of guests > max_guests[0] -> @max_guests = (guests, current_time)
    foreach my $time ($min_time..$max_time) {
        if (exists $leave_times{$time}) {
            $guests -= $leave_times{$time};
        }
        if (exists $entry_times{$time}) {
            $guests += $entry_times{$time};
            @max_guests = ($guests, $time) if ($guests > $max_guests[0]);
        }
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
