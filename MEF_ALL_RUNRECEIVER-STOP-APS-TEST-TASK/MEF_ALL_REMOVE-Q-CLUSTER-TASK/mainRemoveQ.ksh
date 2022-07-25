#!/bin/ksh
#user:mqm
#group:mqm
#interp:sol

# Added by PAdelaide - ESM = 10/17/2011
# Updated for multi logging by PAdelaide - IBM/IRS - 05/18/2018
 
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/parasoftAddQCluster.sh)
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

chmod 644 $log

#
# start
#
date
pwd
id

print ""
print ""
print ""

#########################

./removeQCluster-Wrapper.ksh
print ""
print ""
print ""
print ""
./statusQCluster-remove-Wrapper.ksh

# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
