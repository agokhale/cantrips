sysctl dev.pcm.3.rec.vchanrate=96000
sysctl dev.pcm.3.play.vchanrate=96000


virtual_oss \
                   -S \
                   -Q 0 \
                   -i 8 \
                   -C 18 -c 18 -r 96000 -b 32 -s 8ms -f /dev/dsp3 \
                   -a 0 -c 2 -m 0,16,1,17 -d dsphi \
                   -a 0 -b 32 -c 16 -m 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15 -d dsp \

#
#                   -a 13 -b 16 -c 2 -m 10,10,11,11 -d vdsp.fld \
#                   -a 0 -b 32 -c 4 -m 4,2,5,3,6,4,7,5 -d vdsp.jack \
#                   -a -3 -b 32 -c 2 -m 14,14,15,15 -d vdsp.zyn \
#                   -e 0,1 \
#                   -a 0 -b 32 -c 8 -m 0,8,1,9,2,8,3,9,4,8,5,9,6,8,7,9 -w vdsp.rec.mic.wav -d vdsp.rec.mic \
#                   -a 0 -b 32 -c 2 -m 0,8,1,9 -w vdsp.rec.master.wav -d vdsp.master.mic \
#                   -a 0 -b 32 -c 2 -m 10,10,11,11 -w vdsp.rec.fld.wav -l vdsp.rec.fld \
#                   -a 0 -b 32 -c 2 -m 12,12,13,13 -w vdsp.rec.jack.wav -l vdsp.rec.jack \
#                   -a 0 -b 32 -c 2 -m 14,14,15,15 -w vdsp.rec.zyn.wav -l vdsp.rec.zyn \
#                   -M o,8,0,0,0,0 \
#                   -M o,9,1,0,0,0 \
#                   -M o,10,0,0,0,0 \
#                   -M o,11,1,0,0,0 \
#                   -M o,12,0,0,0,0 \
#                   -M o,13,1,0,0,0 \
#                   -M o,14,0,0,0,0 \
#                   -M o,15,1,0,0,0 \
#                   -M i,14,14,0,1,0 \
#                   -M i,15,15,0,1,0 \
#                   -M x,8,0,0,1,0 \
#                   -M x,8,1,0,1,0 \
#                   -t vdsp.ctl
#
