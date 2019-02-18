#!/bin/sh -x
echo seeking $1
dtrace -n '
inline string opt_name = "$1";

profile-345 / execname == opt_name / { 
	@[ ustack ()] = count ();  
}


' -o  sammpled.$1.stacks
