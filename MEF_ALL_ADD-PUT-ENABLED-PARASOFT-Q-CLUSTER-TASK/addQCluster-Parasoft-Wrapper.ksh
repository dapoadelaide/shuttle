#!/bin/bash
#user:mqm
#group:mqm
#interp:sol

#####################################################
# AddQCluster.ksh                                   #
# ================================================= #
# Note:  This script must be executed as "mqm".     #
# ================================================= #
# This script is for a Tivoli Task.  The script     #
# executes the "addQCluster" script that must       #
# reside in /var/mqm/scripts.  This script will add #
# local queues into a specified Cluster on a        #
# specific Queue Manager.                           #
# ================================================= #
# Parameters are:                                   #
#    (1) Queue Manager Name              Required.  #
#    (2) Cluster Name                    Required.  #
#    (3) File Name                       Required.  #
#####################################################

# Added by PAdelaide - ESM = 10/17/2011
# Updated for multi logging by PAdelaide - IBM/IRS - 05/18/2018
 
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/parasoftAddQCluster.sh)
####################################################################################################

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

#########################

if [ $# -eq 3 ]; then
   qmgr_name=$1
   cluster_name=$2
   file_name=$3

elif [ $# -eq 0 ]; then
     # use default parameters
     qmgr_name=`dspmq | grep QMNAME | awk -F'(' '{print $2}' | awk -F')' '{print $1}' | sed -n "1p"`
     cluster_name=AMDAS_WEBAPP_CLUSTER
     file_name=/var/mqm/scripts/parasoftQList.txt

else
    # write incorrect # of arguments passed
    echo "ERROR: Incorect # of arguments passed to script - Aborting..."
    exit
fi

#  /var/mqm/scripts/parasoftAddQCluster.sh  $1 $2 $3
# echo "Command: [su - mqm -c cd /var/mqm/scripts; /var/mqm/scripts/parasoftAddQCluster.sh $qmgr_name $cluster_name $file_name]"
echo "Command: [su - mqm -c cd /var/mqm/scripts; /var/mqm/scripts/parasoftAddQCluster.sh $qmgr_name $file_name]"
# su - mqm -c "cd /var/mqm/scripts; /var/mqm/scripts/parasoftAddQCluster.sh $qmgr_name $cluster_name $file_name"
su - mqm -c "cd /var/mqm/scripts; /var/mqm/scripts/parasoftAddQCluster.sh $qmgr_name $file_name"

# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #
