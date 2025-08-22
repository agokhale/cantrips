#!/bin/sh -xe

dev=/dev/dsp9
jackd -m  -t 200 -p 2048 -R  -d oss -r 96000  -C ${dev} -P ${dev}
