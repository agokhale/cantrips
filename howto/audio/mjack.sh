#!/bin/sh -xe

jackd -m  -t 200 -p 2048 -R  -d oss -r 96000  -C /dev/dsp3 -P /dev/dsp3
