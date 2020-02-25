#!/usr/bin/perl

use v5.24;
use warnings;

use threads;
use threads::shared;

use List::Util ('sum');

use Data::Dumper;

=encoding UTF-8

=head1 Time for counter to overflow

What is the expected time for 64-bit counter to overflow? Counter does nothing
but endlessly increase.

=head1 Detecting collisions and keeping the memory consumption under control

Given an endless stream of events, detect and sort out/detect collisions that
are happening within time limit (say, 10 seconds). Memory should be saved, and
old events should be discarded after some time.

=cut

# THE COUNTER TASK
{
    # The counter itself
    my $c :shared = 0;
    my $c_64bit = 2 ** 64;

    # Step for approximation
    my $steps = 10; # also seconds

    # Run the shared counter and nothing else
    my $c_thread = async {
        $SIG{'KILL'} = sub { threads->exit() };
        $c++ while 1;
    };
    $c_thread->detach();

    my ($start, $end, $increment) = ($c, 0, 0);
    my $seconds_in_year = 3600 * 24 * 365;
    my @results;

    for (my $step = 0; $step < $steps; $step++) {
        sleep 1;
        $end = $c;
        $increment = $end - $start;
        $start = $end;
        push (@results, ($c_64bit / $increment) / $seconds_in_year);
    }

    $c_thread->kill('KILL');

    # Discard first result
    shift(@results);
    my $simple_avg = sum(@results) / scalar @results;

    say "At this speed overflowing the 64-bit shared variable will take $simple_avg years.";

    # Just a "bare" counter
    eval {
        my $c = 0;
        local $SIG{ALRM} = sub { die "$c\n" };
        alarm $steps;
        $c++ while 1;
    }; if ($@) {
        my $straight_c = int $@;
        $straight_c /= $steps;
        my $straight_result = ($c_64bit / $straight_c) / $seconds_in_year;
        say "At this speed overflowing the 64-bit variable will take $straight_result years.";
    }
}

# THE COLLISIONS TASK
{
    use experimental 'signatures';
    my $n_events = 1_000_000;

    while ($n_events--) {
        DetectCollision(GenerateEvent());
    }

    sub GenerateEvent {
        state @charset = ('a'..'z', 0..9);
        state $timestamp = 0;
        my $id = $charset[rand @charset] . $charset[rand @charset];
        $timestamp += int(rand(200) - 10); # some chance of "collision"
        return ($id => $timestamp);
    }

    sub DetectCollision(%event) {
        state @seen;
        state $criterion = 10; # shouldn't happen within 10 "ticks"
        state $count = 0;
        state $granularity = 3;
        state $threshold = 100_000;
        state $prev_c = '';

        my ($k, $v) = each %event;

        $count++;
        unless ($count % $threshold) {
            pop(@seen) if (scalar @seen == $granularity);

            unshift(@seen, {});
        }

        foreach my $lookup (@seen) {
            if (exists $lookup->{$k}) {
                if (abs($v - $lookup->{$k}) < $criterion) {
                    next if ($prev_c eq "${k}$lookup->{$k}");
                    $prev_c = "${k}$lookup->{$k}";
                    say "Collision detected! - ($k => $v) and ($k => $lookup->{$k})";
                }
            }

            $lookup->{$k} = $v;
        }
    }

}
