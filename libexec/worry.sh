#!/bin/sh
while  true; do
clear
( echo  $*)
(   $* )
sleep  ${WORRY_SLEEP:=3}
done; 

