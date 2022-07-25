#!/bin/ksh
#user:mqm
#group:mqm
#interp:sol

#####################################################
# PutEnableQCluster.ksh                             #
# ================================================= #
# Note:  This script must be executed as "mqm".     #
# ================================================= #
# This script is for a Tivoli Task.  The script     #
# executes the " script that must                   #
# reside in /var/mqm/scripts.  This script will     #
# change the PUT Status to Enabled for a list of    #
# queues from a file.                               #
# ================================================= #
# Parameters are:                                   #
#    (1) Queue Manager Name              Required.  #
#    (2) Full filename of list of Queues Required.  #
#####################################################

# added by PAdelaide - ESM = 10/17/2011
# Updated for logging by PAdelaide - IBM/IRS - 05/19/2018
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/addQCluster.ksh)
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

if [ $# -eq 2 ]; then
   qmgr_name=$1
   file_name=$2

elif [ $# -eq 0 ]; then
     # use default parameters
     qmgr_name=`dspmq | grep QMNAME | awk -F'(' '{print $2}' | awk -F')' '{print $1}' | sed -n "1p"`
     file_name=/var/mqm/scripts/parasoftQList.txt

else
    # write incorrect # of arguments passed
    echo "ERROR: Incorect # of arguments passed to script - Aborting..."
    exit
fi

# /var/mqm/scripts/parasoftPutEnableQCluster.sh  $1 $2
echo "Command: [su - mqm -c cd /var/mqm/scripts;  /var/mqm/scripts/parasoftPutEnableQCluster.sh $qmgr_name $file_name]"
su - mqm -c "cd /var/mqm/scripts; /var/mqm/scripts/parasoftPutEnableQCluster.sh $qmgr_name $file_name"

#
# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
