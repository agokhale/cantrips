#!bin/sh
#interpolation ctsy of sh
#echo -n \

/usr/sbin/dtrace -n \
'
/* 
dt_all_syscall_latency_by_execname.dt cron


*/
syscall:::entry  /execname == "'$1'"/ 
	{
	self->starttime = timestamp;
	}

syscall:::return  /execname == "'$1'"/ 
	{
	@["delta(ns)",probefunc]  =  quantize ( timestamp - self->starttime); 
	self->starttime = 0 ; 
	}
'
