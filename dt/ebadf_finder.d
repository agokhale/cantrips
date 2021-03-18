#!/usr/sbin/dtrace -s


/* substript to paint probes */
syscall::fstatat:entry /execname == "stat"/ { self->traceme=1;}
syscall:::entry,
fbt:::
 /self->traceme == 1/  
	{
	@probes[probefunc] = count(); 
	}
/*
*/

fbt::biofinish:entry /  arg2==9/ 
{ @exits[probefunc,arg1,errno,stack()]=count();}


:zfs::set-error  /arg0 == 9/
{ @zfserrors[probefunc, probename,stack()]=count();}

/* things that return or set errno */
fbt::freebsd32_cap_ioctls_get:return ,

/* probes are are static, elided .. or other dark matter
fbt::zfs_file_write_impl:return ,
fbt::zfs_file_read_impl:return , 
fbt::zed_file_lock:return , 
fbt::vop_stdioctl:return , 
fbt::vop_stdstat:return , 
fbt::zfs_file_get:return , */

fbt::kern_do_statfs:return , 
fbt::kern_getdirentries:return , 
fbt::vdev_validate:return , 
fbt::zfs_onexit_fd_hold:return , 
fbt::fget_cap:return , 
fbt::vn_ioctl:return , 
fbt::vop_ebadf:return , 
fbt::fget:return , 
fbt::sys_fstatat:return , 
fbt::kern_statat:return , 
fbt::kern_lseek:return , 
fbt::freebsd32_ioctl:return 
/arg0 == 9  || errno == 9/ 
{ @exits[probefunc,arg1,errno,stack()]=count();}



/* death from boredom tick-2s { exit(0);}  */
