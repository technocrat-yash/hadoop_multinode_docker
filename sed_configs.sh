#!/bin/bash
server_ip=$1
username=$2
master_ip=$3
ssh $username@$server_ip "sudo sed -i 's|hadoop-master|$master_ip|g' /home/hadoop/hadoop/etc/hadoop/core-site.xml && sudo sed -i 's|hadoop-master|$master_ip|g' /home/hadoop/hadoop/etc/hadoop/hdfs-site.xml && sudo sed -i 's|hadoop-master|$master_ip|g' /home/hadoop/hadoop/etc/hadoop/mapred-site.xml && sudo sed -i 's|hadoop-master|$master_ip|g' /home/hadoop/hadoop/etc/hadoop/yarn-site.xml"