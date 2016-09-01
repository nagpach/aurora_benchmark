#!/bin/bash

sysbench \
  --mysql-host=${mysql_host} \
  --mysql-user=${mysql_user} \
  --mysql-password=${mysql_password} \
  --mysql-db=${mysql_db} \
  --test=/home/ec2-user/sysbench/sysbench/tests/db/parallel_prepare.lua \
  --oltp_tables_count=100 \
  --oltp-table-size=20000000 \
  --rand-init=on \
  --num-threads=32 \
  run
