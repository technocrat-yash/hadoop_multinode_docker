#!/usr/bin/expect -f

set server_ip [lindex $argv 0];
set username [lindex $argv 1];
set password [lindex $argv 2];
set timeout 4
spawn scp workers $username@$server_ip:/home/hadoop/hadoop/etc/hadoop/workers
expect "*assword\r"
send -- "$password\r"
expect eof