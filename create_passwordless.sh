#!/bin/bash

username=hadoop
password=123
i=0

for server_ip in `cat server_list`
do
        if [ $i == 0 ]
        then
                i=1
                ./keygen_authorize.sh $server_ip $username $password
        else
                master_ip=`cat server_list | head -1`
                ./keygen_authorize.sh $server_ip $username $password
                ./copy_to_slaves.sh $master_ip $server_ip $username $password
        fi
done