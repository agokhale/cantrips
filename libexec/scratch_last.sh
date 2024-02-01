#!/bin/sh
d=${HOME}/.scratch
lf=$(ls -rt ${d} | tail -1)
echo $d/$lf
