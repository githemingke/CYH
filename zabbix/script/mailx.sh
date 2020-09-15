#!/bin/bash
export LANG=en_US.UTF-8
SENT_TO=$1
SENT_SUBJECT=$2
echo "$3" > "/tmp/zabbix_mailbody_$$"
dos2unix "/tmp/zabbix_mailbody_$$"
#echo "$SENT_CONTENT" |mailx -s "$SENT_SUBJECT" $SENT_TO
mailx -s "$SENT_SUBJECT" $SENT_TO < "/tmp/zabbix_mailbody_$$"
rm -f "/tmp/zabbix_mailbody_$$"
