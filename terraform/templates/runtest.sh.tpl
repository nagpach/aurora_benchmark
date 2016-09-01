#!/bin/bash

mkdir -p /home/ec2-user/${test_path}_${test_system}_1
for threads in 1 2 4 8 16 32 64 128 256 512 1024
do

sysbench \
  --mysql-host=${mysql_host} \
  --mysql-user=${mysql_user} \
  --mysql-password=${mysql_password} \
  --mysql-db=${mysql_db} \
  --db-ps-mode=disable \
  --rand-init=on \
  --test=/home/ec2-user/sysbench/sysbench/tests/db/oltp.lua \
  --oltp-read-only=off \
  --oltp_tables_count=100 \
  --oltp-table-size=20000000 \
  --oltp-dist-type=uniform \
  --percentile=99 \
  --report-interval=1 \
  --max-requests=0 \
  --max-time=1800 \
  --num-threads=\$threads \
  run | tee ${test_path}/${test_name}_\$threads.out
 
done
