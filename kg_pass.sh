#!/bin/bash
server_ip=$1
username=$2
ssh $username@$server_ip "mkdir -p /home/hadoop/.ssh && chmod 700 /home/hadoop/.ssh && ssh-keygen -t rsa -P \"\" -f id_rsa && mv id_rsa.pub /home/hadoop/.ssh/ && cp /home/hadoop/.ssh/id_rsa.pub /home/hadoop/.ssh/authorized_keys && chmod 640 /home/hadoop/.ssh/authorized_keys && mv id_rsa /home/hadoop/.ssh/"