#!/bin/ksh
#user:mqm
#group:mqm
#interp:sol

# Added by PAdelaide - ESM - 10/17/2011
# Updated for multi logging by PAdelaide - IBM/IRS - 05/18/2018
 
# task is run by root, therefore 'dspmq' command binaries will be sourced correctly for the root id.
# but mqm id is used to run the core script (/var/mqm/scripts/removeQCluster.ksh)
# updated by PA - 09/26/2018
####################################################################################################

receiverAddr="$1"

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
date
pwd
id

print ""
print ""
print "*** Running: ./statusQCluster-remove-Wrapper.ksh ***"
print ""
./statusQCluster-remove-Wrapper.ksh
print ""
print "*** Running: ./removeQCluster-Wrapper.ksh ***"
print ""
./removeQCluster-Wrapper.ksh
print ""
print "*** Running: ./statusQCluster-remove-Wrapper.ksh ***"
./statusQCluster-remove-Wrapper.ksh
print ""
#
print ">>>>> greping [/tmp/GREPTHIS-STATUSQ.log] for 'Returned Status: 10' <<<<<<<"
grep "Returned Status: 10" /tmp/GREPTHIS-STATUSQ.log
remQ_rc=$?
print "Reurn Code of grep of 'Returned Status: 10' in /tmp/GREPTHIS-STATUSQ.log ...  rc:[$remQ_rc]"
if [ $remQ_rc -eq 0 ]; then
   print "Ok: removeQCluster-Wrapper.ksh successful [$remQ_rc]... continue to Put Disabled Q."
   print ""
   print "*** Running: ./putDisableQCluster-Wrapper.ksh ***"
   ./putDisableQCluster-Wrapper.ksh
   print ""
   print "*** Running: ./verifyPutDisabled-disabled-Wrapper.ksh ***"
   ./verifyPutDisabled-disabled-Wrapper.ksh
else
   print "ERROR: removeQCluster-Wrapper.ksh failed [$remQ_rc]... exiting."
 fi

chmod 644 $log
# exit

# ==================== #
# END OF SHELL SCRIPT. #
# ==================== #

#
#########################################################

# do emailing

messageBody=/tmp/messageBody
cat /dev/null >${messageBody}

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

