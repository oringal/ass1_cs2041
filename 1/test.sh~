#!/bin/bash

for file in *.py
do
    filename=${file%.*}
    echo "testing $file"
    ../python2perl.pl< "$file" > "$filename.out.pl"
    echo "executing perl files for testing"
    perl "$filename.pl" > correct.txt
    perl "$filename.out.pl" > test.txt
    echo "Comparing files"
    diff correct.txt test.txt
    if [ $? -ne 0 ]
	then
		echo "test fail"
	else 
		echo "test success"
	fi
done
