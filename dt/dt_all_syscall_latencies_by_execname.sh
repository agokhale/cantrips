#!/bin/sh
#interpolation ctsy of sh
#echo -n \

/usr/sbin/dtrace -n \
'
#pragma D option bufsize=264M
#pragma D option aggsize=264M
#pragma D option switchrate=1009hz
#pragma D option dynvarsize=1009M

#pragma D option aggrate=1009hz

/* 
#pragma D option quiet
dt_all_syscall_latency_by_execname.dt cron


*/
syscall:::entry  /execname == "'$1'"/ 
	{
	self->starttime = timestamp;
	}

syscall:::return  /execname == "'$1'" && self->starttime / 
	{
	@["delta(us)",probefunc]  =  quantize ( (timestamp - self->starttime) / 1000); 
	self->starttime = 0 ; 
	}
'
