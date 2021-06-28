#!/bin/bash
username=hadoop
password=123

echo "Adding workers in local workers file"
cat server_list | grep -v `cat server_list | head -1` > workers

echo "Copying workers to the containers"
for i in `cat server_list`
do
./copy_workers.sh $i $username $password
done