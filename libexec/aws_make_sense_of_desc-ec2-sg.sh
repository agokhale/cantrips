#!/bin/sh 
#set -x
aws ec2 describe-security-groups \
	| jq -r \
'.SecurityGroups[]|(.Descripton + .GroupId + "   " + .GroupName + "  \n " + (.IpPermissions | tojson)  + "\n")' 
