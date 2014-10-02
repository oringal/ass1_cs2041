#!/bin/bash
echo "Running python2perl on hello_world.py" 
../python2perl.pl < hello_world.py > out.pl 
echo "Running hello_world.pl & out.pl"
perl hello_world.pl > correct.txt
perl out.pl > output.txt
echo "comparing output"
diff correct.txt output.txt
if [ $? -ne 0 ]
then
    echo "test fail"
else
    echo "test success"
fi

