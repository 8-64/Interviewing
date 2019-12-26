#!/usr/bin/perl

use v5.24;
use warnings;

use Test::More;
use Benchmark ':hireswallclock';

my @data = ();
push (@data, int rand 10000) for 1..250;

# 1) Bubble sort
sub BubbleSort {
    my @data = @_;
    my $sorted = 0;

    return (@data) if (scalar @data < 2);

    until ($sorted) {
        my $i = 0; $sorted = 1;
        until ($i == $#data) {
            if ($data[$i] > $data[$i+1]) {
                ($data[$i], $data[$i+1]) = ($data[$i+1], $data[$i]);
                $sorted = 0;
            }
            $i++;
        }
    }

    return @data;
}

# 2) Quick $sort
sub QuickSort {
    my @data = @_;
    my ($pivot, @left, @right);

    return (@data) if (scalar @data < 2);

    $pivot = pop @data;
    foreach (@data) {
        ($_ < $pivot) ? push (@left, $_) : push (@right, $_);
    }

    return (QuickSort(@left), $pivot, QuickSort(@right));
}

# 3) Insertion sort
sub InsertionSort {
    my @data = @_;
    my ($min_position, $min_value);

    for (my $i = 0; $i != $#data; $i++) {
        my $pos = $i;
        $min_position = $i;
        $min_value = $data[$i];

        foreach (@data[$i..$#data]) {
            if ($_ < $min_value) { $min_value = $_; $min_position = $pos;}
            $pos++;
        }

        ($data[$i], $data[$min_position]) = ($data[$min_position], $data[$i]);
    }

    return @data;
}

# 4) Merge sort
sub MergeSort {
    return (@_) if (scalar @_ < 2);

    # Split into 1-element groups
    my @data = map { [$_] } @_;

    # Perform the merge
    my $merge_pos = 0;
    until (scalar @data == 1) {
        my ($A, $B) = splice(@data, $merge_pos, 2);
        my $C = [];
        $A //= []; $B //= [];

        while (scalar(@$A) or scalar(@$B)) {
            my ($left)  = $A->[0] if scalar(@$A);
            my ($right) = $B->[0] if scalar(@$B);

            # One of the arrays is empty -> attach the rest of other
            unless (defined $right) { push(@$C, shift @$A); next; }
            unless (defined $left) { push(@$C, shift @$B); next; }

            ($left < $right) ? push(@$C, shift @$A) : push(@$C, shift @$B);
        }

        splice(@data, $merge_pos, 0, $C);
        $merge_pos++;

        my $remaining = (scalar(@data) - $merge_pos);
        if ($remaining < 2) { $merge_pos = 0 }
    }

    return @{ $data[0] };
}

# 5) Stooge sort
sub StoogeSort {
    my @data = @_;

    return (@data) if (scalar @data < 2);
    (@data[0,-1]) = (@data[-1,0]) if ($data[0] > $data[-1]);
    return (@data) if (scalar @data == 2);

    # Three elements may lead to an endless loop
    if (scalar @data == 3) {
        return (@data) if ($data[0] <= $data[1] and $data[1] <= $data[2]);
        return (@data[2,1,0]) if ($data[0] > $data[1] and $data[1] > $data[2]);

        return (@data[0,2,1]) if ($data[0] <= $data[1] and $data[1] > $data[2] and $data[0] <= $data[2]);
        return (@data[2,0,1]) if ($data[0] <= $data[1] and $data[1] > $data[2] and $data[0] > $data[2]);

        return (@data[1,2,0]) if ($data[0] > $data[1] and $data[1] < $data[2] and $data[0] > $data[2]);
        #return (@data[1,0,2]) if ($data[0] > $data[1] and $data[1] < $data[2] and $data[0] <= $data[2]);
        return (@data[1,0,2]);
    }

    my @left = @data[0..int($#data * 2/3)];
    @data[0..int($#data * 2/3)] = StoogeSort(@left);

    my @right = @data[int($#data * 1/3)..$#data];
    @data[int($#data * 1/3)..$#data] = StoogeSort(@right);

    @left = @data[0..int($#data * 2/3)];
    @data[0..int($#data * 2/3)] = StoogeSort(@left);

    return @data;
}

# 6) Pancake sort
sub PancakeSort {
    my @data = @_;
    my $n = scalar @data;
    return (@data) if ($n < 2);

    my ($max_v, $max_pos);

    while ($n--) {
        ($max_v, $max_pos) = ($data[0], 0);
        my $i = 0;
        foreach (@data[0..$n]) {
            if ($_ > $max_v) { $max_v = $_; $max_pos = $i }
            $i++;
        }

        @data[0..$max_pos] = reverse(@data[0..$max_pos]);
        @data[0..$n] = reverse(@data[0..$n]);
    }

    return (@data);
}

# 7) Gnome sort
sub GnomeSort {
    my @data = @_;
    return (@data) if (scalar @data < 2);

    my $pos = 0;
    until ($pos == $#data) {
        if ($data[$pos] > $data[$pos + 1]) {
            (@data[$pos, $pos+1]) = (@data[$pos+1, $pos]);
            $pos and $pos--;
        } else {
            $pos++;
        }
    }

    return (@data);
}

# 8) Odd-even sort
sub OddEvenSort {
    my @data = @_;
    return (@data) if (scalar @data < 2);

    my $done = 0;
    until ($done) {
        $done = 1;

        for (my $i = 0; $i < $#data; $i += 2) {
            if ($data[$i] > $data[$i+1]) {
                (@data[$i, $i+1]) = (@data[$i+1, $i]);
                $done = 0;
            }
        }
        for (my $i = 1; $i < $#data; $i += 2) {
            if ($data[$i] > $data[$i+1]) {
                (@data[$i, $i+1]) = (@data[$i+1, $i]);
                $done = 0;
            }
        }
    }

    return (@data);
}

# Autodetect sorts
my @sorts;
foreach (keys %::) {
    if (/Sort$/) {
        push(@sorts, [ $_, \&$_]);
    }
}

# Sort sorts :-)
@sorts = sort { $a->[0] cmp $b->[0] } @sorts;

# Run them all, test and benchmark
my @compare = ();
foreach my $sort (@sorts) {
    say "\nRunning $sort->[0]:";

    my $t0 = Benchmark->new;
    my @sorted = $sort->[1]->(@data);
    my $t1 = Benchmark->new;
    say 'Sort took: ' . timestr(timediff($t1, $t0));

    say "Unsorted/sorted array sizes: @{[scalar @data]}/@{[scalar @sorted]}";
    if (scalar @compare) {
        is_deeply(\@sorted, \@compare, "Are results from $sort->[0] the same as in previous case?");
    }
    @compare = @sorted;
}
done_testing();
