#!/usr/sbin/dtrace -s

*spot*:::*-entry
{
@[probename,"hotspot"] = count();
}
 
syscall:::entry
/strstr(execname, "java") > 0 /
{
@[probefunc, "sys"] = count();
}

:::tick-3s  { 
    printa(@); clear(@);
}
