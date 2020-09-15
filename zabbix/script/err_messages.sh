#!/bin/bash
tail -500 /var/log/messages | egrep -i "(failed|error)"
if [ $? -eq 0 ];then 
	echo "messages have failed or error"
else
	echo "messages is nomal"
fi
