#!/usr/bin/perl

use v5.24;
use warnings;

use Getopt::Long;

use constant {
    MODEL    => 0,
    LOCATION => 1,
    YEAR     => 2,
    VIN      => 3,
};

my %OPT = (
    "file"     => 'data.csv',
    "input_s"  => ',',
    "output_s" => ',',
    "use_tabs" => 0,
);

my @fields = qw(model location year VIN make);

GetOptions (
    "file=s"     => \$OPT{file},
    "input_s=s"  => \$OPT{input_s},
    "output_s=s" => \$OPT{output_s},
    "use_tabs"   => \$OPT{use_tabs}
) or die("Error in command line arguments\n");
if ($OPT{use_tabs}) {
    $OPT{input_s} = $OPT{output_s} = "\t";
}

open (my $CSV_FH, '<', $OPT{file}) or die ("Cannot open the file $OPT{file}");

my @output;
while (my $line = <$CSV_FH>) {
    chomp($line);
    my (@cells) = split($OPT{input_s}, $line, 5);

    my $changed = 0;

    # Run some checks and corrections
    # 1)
    if ($cells[MODEL] eq 'Cayman' and $cells[YEAR] >= 2007) {
        $cells[VIN] =~ s/U/S/g;
        $changed++;
    }

    # 2)
   if ($cells[VIN] =~ /00001\Z/ and $cells[LOCATION] eq 'Chicago') {
        $cells[LOCATION] = 'St. Louis';
        $changed++;
    }

    if ($changed) {
        push(@output, [ @cells ]);
    }
}

@output = sort { $a->[VIN] cmp $b->[VIN] } @output;

foreach my $line (@output) {
    say join($OPT{output_s}, @$line);
}
