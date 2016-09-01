#!/bin/sh
 
test_path=.
test_name=01_baseline
 
echo "\n" > ${test_path}/${test_name}_all.csv
for threads in 1 2 4 8 16 32 64 128 256 512 1024
do
 
grep "^\[" ${test_path}/${test_name}_${threads}.out \
    | cut -d] -f2 \
      | sed -e 's/[a-z ]*://g' -e 's/ms//' -e 's/(99%)//' -e 's/[  ]//g' \
        >> ${test_path}/${test_name}_all.csv
 
done
