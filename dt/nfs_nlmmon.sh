#!/bin/sh

dtrace -n '
::nlm*:return 
{@nlmret[arg0,probefunc] = count() } 

nfscl:::start 
{
@nfscl[probefunc] = count(); 
}
'
