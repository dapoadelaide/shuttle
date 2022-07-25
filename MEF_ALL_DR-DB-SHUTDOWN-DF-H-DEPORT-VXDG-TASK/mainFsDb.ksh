#!/bin/ksh
#user:
#group:
#interp:

#PAdelaide - IBM/IRS - 10/04/2018
# 
####################################################################################################

# clear the logfile
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

# chmod 644 $log

#
# start
#
print "script:[$0]"
date
pwd
id
#
#########################################################

if [ -z "$1" ]; then
   sleepShutdown=600
 else
   sleepShutdown=$1
fi
if [ -z "$2" ]; then
   sleepDepot=300
  else
   sleepDepot=$2
fi

msgOut(){
 print "[`date '+%m/%d/%Y %H:%M:%S'`]: $msg ..."
}

exiT(){
  exit 1
}

print ""
print "################################### [df -h|grep mef-] #####################################################################################"

msg="Running 'df -h|grep mef-' - 1 of 7 actions...[df -h|grep mef-]"
msgOut
df -h|grep mef-

print ""
print "################################### [/disaster_recovery/dr_db_shutdown.ksh] #################################################################"

msg="Running 'shutdown' -  2 of 7 actions...[/disaster_recovery/dr_db_shutdown.ksh]"
msgOut
/disaster_recovery/dr_db_shutdown.ksh
rc=$?
msg="Return Code [/disaster_recovery/dr_db_shutdown.ksh] [rc:$rc]"
msgOut

print ""
print "################################## [Sleep for [$sleepShutdown] seconds after shutdown] #######################################################"

msg="Running 'sleep' - 3 of 7 actions...[Sleep for [$sleepShutdown] seconds after shutdown]"
msgOut
sleep "$sleepShutdown"  
rc=$?
msg="Return Code [Woke up from sleep] [rc:$rc]"
msgOut

print ""
print "################################### [df -h|grep mef-] #######################################################################################"

msg="Running 'df -h|grep mef-' again - 4 of 7 actions...[df -h|grep mef-]"
msgOut
df -h|grep mef-
rc=$?
if [ $rc -eq 0 ]; then
     msg="WARNING: [mef-*] STILL MOUNTED , cannot Deport now ...exiting script"
     msgOut
     exiT
   else
     msg="[mef-*] SUCCESSFULLY DISMOUNTED will proceed to deport..."
     msgOut
fi
msg="Return Code [df -h|grep mef-] [rc:$rc]"
msgOut

print ""
print "################################################# Deport ##################################################################################"
msg="Running 'Deport' - 5 of 7 actions ...[/disaster_recovery/dr_db_deport.ksh]"
msgOut
/disaster_recovery/dr_db_deport.ksh
rc=$?
msg="Return Code [/disaster_recovery/dr_db_deport.ksh] [rc:$rc]"
msgOut

print ""
print "############################################ Sleep $sleepDepot seconds after Deport ########################################################"
msg="Running 'sleep' - 6 of 7 actions...[Sleep for $sleepDepot seconds after Deport]"
msgOut
sleep "$sleepDepot" 
rc=$?
msg="Return Code [Woke up from sleep] [rc:$rc]"
msgOut

print ""
print "################################################# vxdg list after Deport ##################################################################"
msg="Running 'vxdg list' -  7 of 7 actions ...[ /usr/sbin/vxdg list ]"
msgOut
/usr/sbin/vxdg list
rc=$?
msg="Return Code [/usr/sbin/vxdg list] [rc:$rc]"
msgOut

chmod 644 $log
exit
# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
