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
