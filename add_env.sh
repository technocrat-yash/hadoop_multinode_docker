#!/bin/bash
username=hadoop
password=123

echo "Adding Environment variables to /etc/environment"

for i in `cat server_list`
do
./copy_env.sh $i $username $password
done