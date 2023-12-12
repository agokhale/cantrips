#!/bin/sh -xe
#workaround for csh being unable to contain stderr + stdout to one stream
printf  "containingt_blast %s", $*
pwd
date +"%s"
( $* ) 2>&1 | cat - 

