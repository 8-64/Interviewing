#!/usr/bin/perl

use v5.24;
use warnings;

while (my $name = glob '.* *') {
    next unless -f $name;
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
