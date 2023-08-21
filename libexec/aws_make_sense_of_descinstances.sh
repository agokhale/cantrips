#!/bin/sh -x
aws ec2 describe-instances | \
jq  -r \
'
.Reservations[].Instances[] | 
	( 
	"state:" + (.State.Name) +
	"   nnt:" +  (  .Tags[] | select(.Key == "Name" ) | .Value )) +
	"   pubip:" + (.NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp )
' | \
sort -r

#'.Reservations[].Instances[].InstanceId, .Reservations[].Instances[].Tags , .Reservations[].Instances[].State.Name, .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp'

