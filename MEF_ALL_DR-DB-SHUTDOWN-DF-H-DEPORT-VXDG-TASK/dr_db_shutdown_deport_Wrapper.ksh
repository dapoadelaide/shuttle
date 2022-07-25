#!/bin/ksh
clear the logfile
log="/tmp/$0.logfile.`date '+%m%d%Y-%H%M%S'`.txt"
# >$log

pipe1="/tmp/regular_pipe.$$"
pipe2="/tmp/error_pipe.$$"
trap 'rm "$pipe1" "$pipe2"' EXIT

disasterDir="/disaster_recovery"
shutDownSleep=600
depotSleep=180
	
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

# run dr_db_shutdown.ksh
clear

print ""
print ""
print ""

print "*** Running [df -h|grep mef before shutdown] ***"
df -h|grep mef
print "Return Code for [df -h|grep mef]:[$?]"
print ""
print ""
print ""

print "*** Running [ $disasterDir/dr_db_shutdown.ksh ] ***"
$disasterDir/dr_db_shutdown.ksh
print "Return Code for [$disasterDir/dr_db_shutdown.ksh]:[$?]"
print ""
print ""
print ""

print "Sleeping for 10 minutes ..........[Started: `date '+%m%d%Y-%H%M%S'`]"
sleep $shutDownSleep
print "Woke up from 10 minutes of sleep..[Woke up: `date '+%m%d%Y-%H%M%S'`]"
print ""
print ""
print ""

print "*** Running [df -h|grep mef after shutdown] ***"
df -h|grep mef
shutdown_rc=$?
print "Return Code for [df -h|grep mef]:[$shutdown_rc]"

#
# deport if shutdown rc is not 0. 
#
if [ $shutdown_rc -ne 0  ]; then
   print "*** Ok: no mef mounts found, proceed to deport ***"
   print "*** Ok: run [vxdg list before deport] ***"
   print "*** Running [/usr/sbin/vxdg list] ***"
   /usr/sbin/vxdg list
   print "Return Code for [/usr/sbin/vxdg list]:[$?]"
   print ""
   print ""
   print ""

   print "*** Running [ $disasterDir/dr_db_deport.ksh ] ***"
   $disasterDir/dr_db_deport.ksh
   deport_rc=$?
   print "Return Code for [$disasterDir/dr_db_deport.ksh]:[$deport_rc]"
   print ""
   print ""
   print ""
else
   print "Return Code for [df -h|grep mef]:[$shutdown_rc]"
   print "*** ERROR: cannot deport at this time, shutdown failed [rc:$shutdown_rc], please investigate, exiting... ***"
   exit 
fi

#
# if depot rc is 0, sleep for 180 secs & perform vxdg list. 
#

if [ $deport_rc -eq 0  ]; then
   print "Sleeping for 3 minutes ..........[Started: `date '+%m%d%Y-%H%M%S'`]"
   sleep $depotSleep
   print "Woke up from 3 minutes of sleep..[Woke up: `date '+%m%d%Y-%H%M%S'`]"
   print ""
   print ""
   print ""

   print "*** Running [vxdg list after deport] ***"
   /usr/sbin/vxdg list
   print "Return Code for [vxdg list]:[$?]"
else
   print "*** ERROR: deport failed,[$disasterDir/dr_db_deport.ksh][rc:$deport_rc] exiting... ***."
   exit 
 fi


exit




