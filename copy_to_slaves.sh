#!/usr/bin/expect -f

set master_ip [lindex $argv 0];
set server_ip [lindex $argv 1];
set username [lindex $argv 2];
set password [lindex $argv 3];
set timeout 4
spawn ssh $username@$master_ip
#expect "yes/no"
#send "yes\r"
expect "*assword\r"
send -- "$password\r"
expect "$\r"
#send -- "scp /home/hadoop/.ssh/authorized_keys $username@$server_ip:/home/hadoop/.ssh/\r"
send -- "ssh-copy-id $username@$server_ip\r"
expect "yes/no"
send -- "yes\r"
expect "*assword\r"
send -- "$password\r"
expect "$\r"
send -- "scp /home/hadoop/.ssh/id_rsa $username@$server_ip:/home/hadoop/.ssh/\r"
expect "$\r"
send -- "scp /home/hadoop/.ssh/id_rsa.pub $username@$server_ip:/home/hadoop/.ssh/\r"
expect "$\r"
send -- "exit\r"
expect eof