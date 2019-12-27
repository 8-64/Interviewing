#!/usr/bin/perl

# Sleepsort implemened separately from other sorting algorithms due to its
# rather specific nature and timing/memory constraints

use v5.24;
use warnings;

use Test::More;

use threads;
use threads::shared 'shared_clone';
use Thread::Queue;

# Sleep for milliseconds
sub Nap ($) { select(undef, undef, undef, $_[0]) }

my @data = ();
my @sorted :shared = ();

push (@data, int rand 100) for 1..25;

sub sleepSort {
    my @data = @_;
    my @workers;
    my $n_of_threads = scalar @data;

    # Create worker threads and queue
    my $queue = Thread::Queue->new();
    foreach (1..$n_of_threads) {
        my $thr = threads->create( sub {
                my $arg = $queue->dequeue();
                #sleep $arg;
                Nap($arg/100); # 100x speedup!
                push(@sorted, $arg);
                say "Sorted $arg";
                return;
            }
        );

        $thr->detach();
        push(@workers, $thr);
    }

    # Start queue
    $queue->enqueue(@data);

    WAIT_FOR_THREADS: {
        #my $remaining_items_in_queue = $queue->pending();
        my $running = 0;
        foreach (@workers) { $running++ if $_->is_running() }
        if ($running) { Nap(0.1); redo }
    }

    # End queue
    $queue->end();
}

sleepSort(@data);

my @compare = sort { $a <=> $b } @data;
is_deeply(\@sorted, \@compare, "Are results from the Sleep Sort the same as from built-in one?");
done_testing();
