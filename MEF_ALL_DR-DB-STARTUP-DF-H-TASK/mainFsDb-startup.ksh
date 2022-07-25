#!/bin/ksh
#user:
#group:
#interp:

#PAdelaide - IBM/IRS - 10/25/2018
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

receiverAddr="$2"

if [ -z "$1" ]; then
   sleepStartup=600
 else
   sleepStartup=$1
fi

msgOut(){
 print "[`date '+%m/%d/%Y %H:%M:%S'`]: $msg ..."
}

exiT(){
  exit 1
}

print ""
print "################################### [df -h|grep mef-] #####################################################################"

msg="Running 'df -h|grep mef-' - 1 of 5 actions...[df -h|grep mef-]"
msgOut
df -h|grep mef-
rc=$?
msg="Return Code [df -h|grep mef-][rc:$rc]"
msgOut

print ""
print "################################### [/disaster_recovery/dr_db_startup.ksh] #################################################################"

msg="Running 'startup' -  2 of 5 actions...[/disaster_recovery/dr_db_startup.ksh]"
msgOut
/disaster_recovery/dr_db_startup.ksh
rc=$?
msg="Return Code [/disaster_recovery/dr_db_startup.ksh] [rc:$rc]"
msgOut

print ""
print "################################## [Sleep for [$sleepStartup] seconds after startup] ################################################################################"

msg="Running 'sleep' - 3 of 5 actions...[Sleep for [$sleepStartup] seconds after startup]"
msgOut
sleep "$sleepStartup"  
rc=$?
msg="Return Code [Woke up from sleep] [rc:$rc]"
msgOut

print ""
print "################################### [/disaster_recovery; ./dr_db_mount_mef.ksh] #####################################################################"

msg="Running '/disaster_recovery; ./dr_db_mount_mef.ksh' - 4 of 5 actions...[/disaster_recovery; ./dr_db_mount_mef.ksh]"
msgOut

cd /disaster_recovery; pwd; ./dr_db_mount_mef.ksh
rc=$?
msg="Sleeping for 60 seconds after /disaster_recovery; ./dr_db_mount_mef.ksh [rc:$rc]"
msgOut
sleep 60

print ""
print "################################### [df -h|grep mef-] #####################################################################"

msg="Running 'df -h|grep mef-' again - 5 of 5 actions...[df -h|grep mef-]"
msgOut
df -h|grep mef-
rc=$?
msg="Return Code [df -h|grep mef-][rc:$rc]"
msgOut

print ""

chmod 644 $log
# exit
# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #

# do emailing

messageBody=/tmp/messageBody
cat /dev/null >${messageBody}

# receiverAddr="$2"
fileToGet="$log"
fileToGet_basename=`basename $log`
fileToGetTMP="/tmp/${fileToGet_basename}"
echo "[$fileToGetTMP]" >${messageBody}  
box=`hostname `
# reply_email="${box} <${senderAddr}>"
subject="[ ${fileToGet_basename} ] from ${box}"
sleep 10

os_name=`uname `
case $os_name in
  SunOS)
    for email in ${receiverAddr}
    do
      reply_email="${box} <${email}>"
      echo "mailx -i -s ${subject} -r ${reply_email} ${email} < ${fileToGetTMP}"
      # mailx -i -s "${subject}" -r "${reply_email}" ${email} < ${fileToGet}
      mailx -i -s "${subject}" -r "${reply_email}" ${email} < ${fileToGetTMP}
      
# mailx -a ${fileToGet} -s "${subject}" -r "${reply_email}" ${email} < ${messageBody}

      echo "${fileToGetTMP} Sent To: [${email}] ..."
    done
  ;;
  Linux)
    for email in ${receiverAddr}
    do
      # echo "mail -i -s ${subject} -r ${reply_email} ${email}<${fileToGetTMP}"
       ls -ltr ${fileToGetTMP}
sleep 15
      # mail -i -s "${subject}" -r "${reply_email}" ${email}<${fileToGetTMP}

      # echo "mailx -a ${fileToGetTMP} -i -s ${subject} -r ${reply_email} ${email} < ${fileToGetTMP}"
      #mailx -a ${fileToGetTMP} -i -s "${subject}" -r "${reply_email}" ${email} < ${fileToGetTMP}

      reply_email="${box} <${email}>"
      echo "mailx -a ${fileToGetTMP} -i -s ${subject} -r ${reply_email} ${email}<${messageBody}"
      mailx -a ${fileToGetTMP} -i -s "${subject}" -r "${reply_email}" ${email}<${messageBody}

      echo "${fileToGetTMP} Sent To: [${email}] ..."
    done
  ;;
  *)
    for email in ${receiverAddr}
    do
      mail -i -s "${subject}" -r "${reply_email}" ${email} < ${fileToGetTMP}
      # mailx -a ${fileToGet} -i -s "${subject}" -r "${reply_email}" ${email} < ${messageBody}
      echo "${fileToGetTMP} Sent To: [${email}] ..."
    done
  ;;
esac
# adios

exit

