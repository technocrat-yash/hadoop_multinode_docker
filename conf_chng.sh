#!/usr/bin/expect -f

set server_ip [lindex $argv 0];
set master_ip [lindex $argv 1]
set username [lindex $argv 2];
set password [lindex $argv 3];
set timeout 4
spawn ./sed_configs.sh $server_ip $username $master_ip
#expect "yes/no"
#send "yes\r"
expect "*assword\r"
send -- "$password\r"
expect eof