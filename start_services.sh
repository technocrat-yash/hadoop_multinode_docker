#!/bin/bash
username=hadoop
password=123

echo "Adding Environment variables to /etc/environment"

for i in `cat server_list | head -1`
do
./hdfs_format.sh $i $username $password
sleep 10
./start_hdfs.sh $i $username $password
sleep 10
./start_yarn.sh $i $username $password
done