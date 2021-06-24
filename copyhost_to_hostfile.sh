#!/bin/bash
nets=`docker network inspect -f '{{json .Containers}}' yash_net | jq -r 'to_entries[] | [.value.IPv4Address, .key] | @csv'`
i=0
max_ip=`echo $nets | awk -F ' ' '{print NF}'`
while [ $i -lt $max_ip ]
do
var=$((i+1))
echo $nets | awk -F ' ' '{print $"'"$var"'"}' | sed 's/\"//g' | sed 's/,/ /g' | sed 's|/| |g' | awk -F ' ' '{print$1" "substr($3,1,12)}' >> server_list_out
i=$((i+1))
done

user=hadoop
for i in `cat server_list_out | awk -F ' ' '{print$1}'`
do
cat server_list_out | sshpass -p '123' ssh $user@$i "sudo chmod 777 /etc/hosts; cat >> /etc/hosts"
done