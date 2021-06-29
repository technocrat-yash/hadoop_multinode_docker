#!/usr/bin/expect -f

set server_ip [lindex $argv 0];
set username [lindex $argv 1];
set password [lindex $argv 2];
set timeout 4
spawn ./ssh_env_copy.sh $server_ip $username
#expect "yes/no"
#send "yes\r"
expect "*assword\r"
send -- "$password\r"
expect eof