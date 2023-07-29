#!/bin/sh -ex
find . -name "*.wav" -print0 | xargs -0 -n1 -I% sox "%" "%".cdr
echo cdrecord dev=3,0,0 -v -audio -dao *.cdr

