#!/bin/sh -ex
abcde -d /dev/cd0 \
	-VV \
	-o wav \
	-f \
	-N

cdcontrol eject
