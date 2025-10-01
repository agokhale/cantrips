#!/bin/sh -xe

now=` date "+%s" `

fns="/tmp/kstack_gazer.$now"
sudo kstack_gazer.dtrace  >  $fns.stacks
dtstackcollapse_flame.pl <  $fns.stacks | flamegraph.pl > $fns.svg
read wat
chrome $fns.svg
