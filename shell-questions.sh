#!/bin/bash

# 1) Using grep, print lines starting with "Host", that contain at least 2 digits afterwards, plus 2 next following lines:
echo "Foobar
Hostabc 435t2
First
Second
Third
Host 2
Host 3
Host 4
host10
Host23
First
Second
Third
" > ./testgrep.txt
grep -E -A 2 --no-group-separator '^Host.*[0-9]{2}' $(find . -name *.txt)

# 2) Print the first and the last lines of the command output
ps -ef | tee >(tail -1 > last.txt) | head -1; cat last.txt
# OR, in Perl:
ps -ef | perl -nE "say if 1..1 or eof"

# 3) Print the first and the third coulums of the command output
ls -ahl | cut -f1,3 -d' '
# OR, in Perl:
ls -ahl | perl -F'\s+' -E 'say "@F[0,2]"'

# 4) Count the number of active processes
ps -ef --no-headers | wc -l
# OR, absolutely precise, without influencing the number by observation:
perl -E '$a=-1; opendir(P, q[/proc]); /\A[0-9]+\Z/ and ++$a while readdir P; say $a'

# 5) Count specific word in a file
grep -ci "\bhost\b" ./testgrep.txt
# OR in Perl
perl -nE 'BEGIN{$w=shift} /\b$w\b/i and $a++; END{say $a}' "host" ./testgrep.txt
