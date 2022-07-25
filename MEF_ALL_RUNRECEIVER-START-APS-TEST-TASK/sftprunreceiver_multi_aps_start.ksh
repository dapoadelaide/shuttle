#!/bin/ksh
clear the logfile
log="/tmp/$0.logfile.`date '+%m%d%Y-%H%M%S'`.txt"
# >$log

receiverAddr="$1"

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

# run script - *.ksh
clear

print ""
print ""
print ""

print "*** Running [su - wasadmin -c cd /opt/csdsftp; ./sftprunreceiver_multi_aps start ***"
su - wasadmin -c "cd /opt/csdsftp; ./sftprunreceiver_multi_aps start"
print "Return Code for [su - wasadmin -c cd /opt/csdsftp; ./sftprunreceiver_multi_aps start]:[$?]"
print ""
print ""
print ""

#########################################################

chmod 644 $log

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

