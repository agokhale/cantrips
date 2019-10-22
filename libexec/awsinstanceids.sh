#!/bin/sh
jtmp=`mktemp awsunconfuse.XX`

aws ec2 describe-instances > $jtmp

if [ $# -eq 0 ]; then
	cat $jtmp | jq "[.Reservations][0][].Instances[].InstanceId" | sed -e "s/[^[:digit:][:lower:]-]//g"

elif [ $1 = "-b" ]; then 
	echo count:
	cat $jtmp | jq '[.Reservations][0][].Instances[].State.Name' | wc -l

	cat $jtmp | \
jq '[.Reservations][0][].Instances[].State.Name ,[.Reservations][0][].Instances[].PublicDnsName, [.Reservations][0][].Instances[].InstanceId, [.Reservations][0][].Instances[].NetworkInterfaces[].Association.PublicIp, [.Reservations][0][].Instances[].Tags[].Value' | \
sed -e 's/"//g'

elif [ $1 =  "-l" ]; then 
	cat $jtmp | jq
fi

rm $jtmp
