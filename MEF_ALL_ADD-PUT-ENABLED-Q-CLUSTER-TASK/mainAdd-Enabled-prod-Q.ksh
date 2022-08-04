#!/bin/bash
#user:mqm
#group:mqm
#interp:sol

# Added by PAdelaide - ESM - 10/17/2011
# Updated for multi logging by PAdelaide - IBM/IRS - 05/18/2018
 
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/addQCluster.ksh)
# updated by PA - 09/26/2018
####################################################################################################

# clear the logfile
log="/tmp/statusQ.logfile.`date '+%m%d%Y-%H%M%S'`.txt"
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

#chmod 644 $log

#
# start
#
date
pwd
id

receiverAddr="$1"

print ""
print ""
print "*** Running: ./statusQCluster-add-Wrapper.ksh ***"
print ""
./statusQCluster-add-Wrapper.ksh
print ""
print "Running: ./addQCluster-Wrapper.ksh ***"
print ""
./addQCluster-Wrapper.ksh
print ""
print "Running: ./statusQCluster-add-Wrapper.ksh ***"
./statusQCluster-add-Wrapper.ksh
print ""
#
print ">>>>> greping [/tmp/GREPTHIS-STATUSQ.log] for 'Returned Status: 0' <<<<<<<"
grep "Returned Status: 0" /tmp/GREPTHIS-STATUSQ.log
addQ_rc=$?
print "Reurn Code of grep of 'Returned Status: 0' in /tmp/GREPTHIS-STATUSQ.log ...  rc:[$addQ_rc]"
if [ $addQ_rc -eq 0 ]; then
   print "Ok: addQCluster-Wrapper.ksh successful [$addQ_rc]... continue to Put Enabled Q."
###./mainPutEnabled.ksh 
   print ""
   print "*** Running: ./putEnableQCluster-Wrapper.ksh ***"
   ./putEnableQCluster-Wrapper.ksh
   print ""
   print "*** Running: ./verifyPutEnabled-enabled-Wrapper.ksh ***"
   ./verifyPutEnabled-enabled-Wrapper.ksh
else
   print "ERROR: addQCluster-Wrapper.ksh failed [$addQ_rc]... exiting."
 fi

chmod 644 $log

# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
#
#########################################################

chmod 644 $log
