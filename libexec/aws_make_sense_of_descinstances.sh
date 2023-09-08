#!/bin/sh 
#set -x
aws ec2 describe-instances | \
jq  -r \
'
.Reservations[].Instances[] | 
	( 
	"state:" + (.State.Name) +
	"   nnt:" +  (  .Tags[] | select(.Key == "Name" ) | .Value )) +
	"   pubip:" + (.NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp ) +
	"   prvip:" + (.NetworkInterfaces[].PrivateIpAddresses[].PrivateIpAddress )
' | \
sort -r

