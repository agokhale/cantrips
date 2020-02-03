#!/bin/sh -x
aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceId, .Reservations[].Instances[].Tags , .Reservations[].Instances[].State.Name, .Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp'

