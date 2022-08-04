#!/bin/bash
#user:mqm
#group:mqm
#interp:sol

#####################################################
# StatusQCluster.ksh                                #
# ================================================= #
# Note:  This script must be executed as "mqm".     #
# ================================================= #
# This script is for a Tivoli Task.  The script     #
# executes the "statusQCluster script that must     #
# reside in /var/mqm/scripts.  This script will look#
# for Cluster Queues in a specified Cluster on a    #
# specific Queue Manager.                           # 
# ================================================= #
# Parameters are:                                   #
#    (1) Cluster Name                    Required.  #
#    (2) Queue Manager Name              Required.  #
#####################################################

# Added by PAdelaide - ESM - 10/17/2011
# Updated for logging by PAdelaide - IBM/IRS - 05/19/2018
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/statusQCluster.ksh)
###################################################################################################


# clear the logfile
log="/tmp/statusQ.logfile.`date '+%m%d%Y-%H%M%S'`.txt"
>$log

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

ECHO ()
{
    echo "`date '+%m/%d/%y %H:%M:%S'` $1"
}

if [ $# -eq 2 ]; then
   cluster_name=$1
   qmgr_name=$2

elif [ $# -eq 0 ]; then
     # use default parameters
     cluster_name=AMDAS_WEBAPP_CLUSTER
     qmgr_name=`dspmq | grep QMNAME | awk -F'(' '{print $2}' | awk -F')' '{print $1}' | sed -n "1p"`

else
    # write incorrect # of arguments passed
    ECHO "ERROR: Incorect # of arguments passed to script - Aborting..."
    exit
fi

ECHO "Command: [su - mqm -c cd /var/mqm/scripts;  /var/mqm/scripts/statusQCluster.ksh $cluster_name $qmgr_name]"
su - mqm -c "cd /var/mqm/scripts; /var/mqm/scripts/statusQCluster.ksh $cluster_name $qmgr_name"


# make copy of log for grepping
#
cp $log /tmp/GREPTHIS-STATUSQ.log
echo "*** Make copy of STATUSQ log to /tmp/GREPTHIS-STATUSQ.log rc:[$?] ***"
chmod 755 /tmp/GREPTHIS-STATUSQ.log
echo "*** chmod 755 /tmp/GREPTHIS-STATUSQ.log rc:[$?] ***"

exit

# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
