#!/bin/ksh
# dr_db_startup_Wrapper.ksh

clear the logfile
log="/tmp/$0.logfile.`date '+%m%d%Y-%H%M%S'`.txt"
# >$log

pipe1="/tmp/regular_pipe.$$"
pipe2="/tmp/error_pipe.$$"
trap 'rm "$pipe1" "$pipe2"' EXIT

mkfifo "$pipe1"
mkfifo "$pipe2"
tee -a $log < "$pipe1" &
tee -a $log >&2 < "$pipe2" &

# Redirect output to a logfile as well as their normal locations
exec >"$pipe1"
exec 2>"$pipe2"

chmod 644 $log

#
# start
#
date
pwd
id

# run dr_db_startup.ksh
clear
print ""
print ""
print ""

print "*** Running [df -h|grep mef before startup] ***"
df -h|grep mef
print "Return Code for [df -h|grep mef]:[$?]"
print ""
print ""
print ""

print "*** Running [ dr_db_startup.ksh ] ***"
/disaster_recovery/dr_db_startup.ksh
print "Return Code for [/disaster_recovery/dr_db_startup.ksh]:[$?]"
print ""
print ""
print ""

print "Sleeping for 10  minutes ..........[Started: `date '+%m%d%Y-%H%M%S'`]"
sleep 600
print "Woke up from 10 minutes of sleep..[Woke up: `date '+%m%d%Y-%H%M%S'`]"
print ""
print ""
print ""

print "*** Running [df -h|grep mef after startup] ***"
df -h|grep mef
print "Return Code for [df -h|grep mef]:[$?]"
