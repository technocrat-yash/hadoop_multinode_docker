!/usr/bin/expect -f

set server_ip [lindex $argv 0];
set username [lindex $argv 1];
set password [lindex $argv 2];
set timeout 4
spawn ssh $username@$server_ip
expect "*assword\r"
send -- "$password\r"
expect "$\r"
send -- "start-yarn.sh\r"
expect "$\r"
expect eof