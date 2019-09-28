#!/bin/sh
netstat -an -finet | awk '// { if  ( ($2>0) || ($3>0)) { print $0;}}' 
