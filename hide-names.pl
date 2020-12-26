#!/usr/bin/perl

use v5.24;
use warnings;

my $args = join(' ', @ARGV);
my $action = 'hide';
if ($args =~ /\bshow\b|\bunhide\b/) {
    $action = 'show';
}

my @filenames = ();
while (my $name = glob '.* *') {
    next unless -f $name;
    push (@filenames, $name);
}

if ($action eq 'show') {
    foreach my $name (@filenames) {
        next if ($name !~ /^\w(?<N>[0-9])+\w\./);

        my $unpacked = ucfirst lc reverse substr($name, 0, rindex($name, '.'));
        $unpacked = substr($unpacked, 0, 1) . ('*' x $+{N}) .  substr($unpacked, -1, 1);
        my $ext = substr($name, rindex($name, '.'));
        say "$name => ${unpacked}${ext}";
    }

    exit 0;
}

foreach my $name (@filenames) {
    my $suggestion = uc reverse substr($name, 0, rindex($name, '.'));
    my $ext = substr($name, rindex($name, '.'));
    $suggestion = substr($suggestion, 0, 1) . (length($suggestion) - 2) . substr($suggestion, -1, 1);
    say "$name => ${suggestion}${ext}";
}

__END__

=encoding UTF-8

=head1 ABOUT

A little tool that suggests short names for scripts that "hide" the names
of companies, so that people who search GitHub for interview questions won't be
finding answers immediately. This way, "Corp.com.pl" file becomes "M6C.pl".

=cut
