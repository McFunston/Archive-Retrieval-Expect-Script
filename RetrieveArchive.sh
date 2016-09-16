#!/usr/bin/expect
exp_internal 1
set timeout 15
set username [lindex $argv 0]
set password [lindex $argv 1]
set hostname [lindex $argv 2]
set pwsuccess [lindex $argv 3]; #set to password success identifier 
set separateretrieve [lindex $argv 4]; # y means that retrieve and number are two separate sends
set jobnumber [lindex $argv 5]
set jobappendix [lindex $argv 6]; #if the job search needs paramaters eg -s 

#findfilesuccess = ""

#log_user 0

if {[llength $argv] == 0} {
  send_user "Usage: scriptname username \'password\' hostname\n"
  exit 1
}

send_user "\n#####\n# $hostname\n#####\n"

spawn telnet $hostname

expect "*assword"

send "\r"

expect "login:"

send "$username\r"

expect {
  timeout { send_user "\nFailed to get password prompt\n"; exit 1 }
  eof { send_user "\nSSH failure for $hostname\n"; exit 1 }
  "*assword"
}

send "$password\r"

expect {
  timeout { send_user "\nLogin failed. Password incorrect.\n"; exit 1}
  "$pwsuccess"  
}

if {separateretrieve == "y"} {
  send "Retrieve";
  expect "";
  send "$jobnumber"
  expect {
    timeout {send_user "\nObject not found"; exit 1}
    "Elapsed processing time"
  }
} else {
  send "$retrieve $jobnumber $jobappendix"
}

send_user "\nPassword is correct\n"
send "exit\r"
close