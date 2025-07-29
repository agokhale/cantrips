#!/bin/sh -xe
# for whatever reason this needs to be run twice, or the audio is distrorted un der 14.2
pcmdev="9"
rate="96000"

sysctl dev.pcm.9.%desc 
# should be 
sysctl dev.pcm.$pcmdev.rec.vchanrate=$rate
sysctl dev.pcm.$pcmdev.play.vchanrate=$rate

#speculative
#	sysctl hw.snd.default_unit=$pcmde
	sysctl hw.snd.verbose=4
	kldload mac_priority.ko || true


#-s 8ms -> 2ms no effect? - minimum is 2
# 2ms -> 1ms bad  feed_root: (virtual) appending 6912 bytes (count=27648 l=20736 feed=1662) bad audio
#at 96000 .002 = 192

rtprio 7 \
virtual_oss \
                   -S \
                   -Q 0 \
                   -i 8 \
                   -C 18 -c 18 -r $rate -b 32 \
		-s 4ms \
		-f /dev/dsp$pcmdev \
                -a 0 -c 2 -m 0,16,1,17 \
		-d dsp 
#\
#                -a 0 -b 32 -c 16 -m 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15 \
#		-d dsphi \

