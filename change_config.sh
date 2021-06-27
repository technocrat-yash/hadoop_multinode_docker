#!/bin/bash

user=hadoop
password=123
master_ip=`cat server_list | head -1`

for server_ip in `cat server_list`
do
    ./conf_chng.sh $server_ip $master_ip $user $password
done