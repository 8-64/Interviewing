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
