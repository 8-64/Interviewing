#!/usr/bin/perl

use v5.24;
use warnings;

use threads;

use List::Util ('min', 'max');
use Time::HiRes ('time');

use Data::Dumper;

=encoding UTF-8

=head1 Algorithmical runtime complexity

Tasks that are related to the improvement of runtime complexity, like going from
O(n) to O(log n).

=head3 LARGEST MINIMUM IN A SUBARRAY

Given huge array A, and a segment of size B, efficiently find the largest number
from the minimal numbers for all the segments.
Essentially, sort of "sliding window" algorithm.
    Dataset:
    around 1_000_000 numbers
    segment size: around 100_000 - 500_000

=cut

my $a_size = 1_000_000;
my @data = ();
while ($a_size--) {
    push(@data, int rand 1_000_000);
}

sub largest_minimum_naive {
    my ($segment, $A) = @_;

    my $N = scalar @$A;
    my @subarray_mins;

    return max(@$A) if ($N == $segment);

    my $j = $segment - 1;
    # Calculate minimal values for each subarray
    for (my $i = 0; $i < $N; $i++) {
        # Exists() works if presumed that the array doesn't have empty cells
        last unless (exists $A->[$i + $j]);
        push (@subarray_mins, min(@{ $A }[$i..$i+$j]));
    }

    return max(@subarray_mins);
}

# Improved implementation of this algorithm
sub largest_minimum_improved_v1 {
    my ($segment, $A) = @_;

    my $N = scalar @$A;
    my @subarray_mins;

    return max(@$A) if ($N == $segment);

    my $j = $segment - 1;

    my (@subarray) = @{ $A }[0..$j];
    my $local_minimum = min(@subarray);
    push (@subarray_mins, $local_minimum);

    # Calculate minimal values for each subarray
    my ($leaving, $coming);
    for (my $i = 1; $i < $N; $i++) {
        # Exists() works if presumed that the array doesn't have empty cells
        last unless (exists $A->[$i + $j]);

        my $leaving = shift(@subarray);
        my $coming = $A->[$i + $j];
        push (@subarray, $coming);

        if    ($coming < $local_minimum)   { $local_minimum = $coming }
        elsif ($leaving == $local_minimum) { $local_minimum = min(@subarray) }

        push (@subarray_mins, $local_minimum);
    }

    return max(@subarray_mins);
}

my %results = with_threaded_timeout(
    'Naive, segment size -> 10' => {
        t_out => 10,
        f     => \&largest_minimum_naive,
        args  => [10, \@data],
    },
    'Naive, segment size -> 100' => {
        t_out => 10,
        f     => \&largest_minimum_naive,
        args  => [100, \@data],
    },
    'Naive, segment size -> 1000' => {
        t_out => 10,
        f     => \&largest_minimum_naive,
        args  => [1000, \@data],
    },
    'Naive, segment size -> 100000' => {
        t_out => 10,
        f     => \&largest_minimum_naive,
        args  => [100_000, \@data],
    },
    'Improved v1, segment size -> 10' => {
        t_out => 10,
        f     => \&largest_minimum_improved_v1,
        args  => [10, \@data],
    },
    'Improved v1, segment size -> 100' => {
        t_out => 10,
        f     => \&largest_minimum_improved_v1,
        args  => [100, \@data],
    },
    'Improved v1, segment size -> 1000' => {
        t_out => 10,
        f     => \&largest_minimum_improved_v1,
        args  => [1000, \@data],
    },
    'Improved v1, segment size -> 100000' => {
        t_out => 10,
        f     => \&largest_minimum_improved_v1,
        args  => [100_000, \@data],
    },
    'Improved v1, segment size -> 500000' => {
        t_out => 10,
        f     => \&largest_minimum_improved_v1,
        args  => [500_000, \@data],
    },
);

$Data::Dumper::Terse = 1;
$Data::Dumper::Sortkeys = 1;
say Dumper(\%results);

# Run algorithms as threads, with time limit
sub with_threaded_timeout {
    my %args = @_;
    my %results;
    my $launch_t = time();

    foreach my $what (keys %args) {
        my ($f, @f_args) = ($args{$what}->{f}, $args{$what}->{args}->@*);
        my $thr = async {
            $SIG{'KILL'} = sub { threads->exit() };
            return $f->(@f_args);
        };
        $args{$what}->{thread} = $thr;
    }

    {
        foreach my $what (keys %args) {
            my $to = $args{$what}->{thread};
            next if ($results{$what}->{done});

            my $diff_t = time() - $launch_t;

            if ($to->is_joinable()) {
                $results{$what} = {
                    result => $to->join(),
                    time   => $diff_t,
                    t_out  => 0,
                    done   => 1,
                };
                next;
            }

            if ($diff_t < $args{$what}->{t_out}) {
                next;
            } else {
                $results{$what} = {
                    result => "Terminated by TIMEOUT ($args{$what}->{t_out} s)",
                    time   => $diff_t,
                    t_out  => 1,
                    done   => 1,
                };
                $to->kill('KILL')->detach();
            }
        }

        redo if (grep { $_->is_running() or $_->is_joinable() } map { $args{$_}->{thread} } keys %args);
    }

    return %results;
}
