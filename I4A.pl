#!/usr/bin/perl

use v5.24;
use warnings;

use Cwd 'cwd';
my $dir = cwd();

say "Running on $^O, testing scenarios:";

my ($f_name, $FH) = MakeFile();
Inform("Created a file [$f_name]:");
FileInfo($FH);

Inform("Turned autoflush on:");
$FH->autoflush(1);
FileInfo($FH);

Inform("Removed the file");
RemoveFile($f_name);
FileInfo($FH);

Inform('Reading the first word:');
say "It is: " . ReadFirstWord($FH);
FileInfo($FH);


sub ReadFirstWord {
    my ($FH) = @_;
    seek($FH, 0, 0);
    my $word = '';
    while (my $line = <$FH>) {
        ($word) = $line =~ /(\b\w+\b)/;
        return $word if (length $word);
    }
    return undef;
}

sub FileInfo {
    my ($FH) = (@_);
    my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
    $atime,$mtime,$ctime,$blksize,$blocks)
       = map { length $_ ? $_ : '[not set]' } stat($FH);
    $mode = sprintf('%o', $mode);
    say <<~"F_INFO";
        Device n:    $dev
        Inode n:     $ino
        Mode:        $mode
        Hard link n: $nlink
        UID:         $uid
        GID:         $gid
        Dev ID:      $rdev
        Size:        $size
        Access time: $atime
        Mod t:       $mtime
        Change t:    $ctime
        Block pref:  $blksize
        Block n:     $blocks
        F_INFO
}

sub MakeFile {
    state $content = <<~'LOREM_IPSUM';
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

        Curabitur pretium tincidunt lacus. Nulla gravida orci a odio. Nullam varius, turpis et commodo pharetra, est eros bibendum elit, nec luctus magna felis sollicitudin mauris. Integer in mauris eu nibh euismod gravida. Duis ac tellus et risus vulputate vehicula. Donec lobortis risus a elit. Etiam tempor. Ut ullamcorper, ligula eu tempor congue, eros est euismod turpis, id tincidunt sapien risus a quam. Maecenas fermentum consequat mi. Donec fermentum. Pellentesque malesuada nulla a mi. Duis sapien sem, aliquet nec, commodo eget, consequat quis, neque. Aliquam faucibus, elit ut dictum aliquet, felis nisl adipiscing sapien, sed malesuada diam lacus eget erat. Cras mollis scelerisque nunc. Nullam arcu. Aliquam consequat. Curabitur augue lorem, dapibus quis, laoreet et, pretium ac, nisi. Aenean magna nisl, mollis quis, molestie eu, feugiat in, orci. In hac habitasse platea dictumst.
        LOREM_IPSUM

    my $f_name = $dir . '/' . RandString(8);

    open(my $FH, '+>>', $f_name) or die("Cannot open [$f_name] - $!");
    say $FH $content;

    return($f_name, $FH);
}

sub RemoveFile {
    my ($f_name) = @_;

    unlink ($f_name) or say("Failed to remove the file! Error - [$!], extended error - [$^E]");
}

sub RandString {
    my @chars = ('a'..'z', 0..9);
    my $len = $_[0];
    my $res = '';
    $res .= $chars[rand @chars] while ($len--);
    $res;
}

sub Inform {
    say "===> $_[0] <===";
}

END {
    Inform("Cleaning up");
    (close $FH)
        ? say 'Closed file handle'
        : say 'Already closed';
    (unlink $f_name)
        ? say "Removed $f_name"
        : say "Already removed $f_name";
}

__END__

=encoding UTF-8

=head1 OPEN FILE WAS DELETED

What happens if open file was deleted? Different scenarios may happen there.

=cut
