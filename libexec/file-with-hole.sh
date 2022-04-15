#!/bin/sh -xe
fil="/tmp/whol"
dd if=/dev/zero bs=512 count=1 > $fil
ls -l $fil
dd if=/dev/zero bs=512 count=1 oseek=10  > $fil
ls -l $fil


