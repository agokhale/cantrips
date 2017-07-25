#!/bin/sh
dtrace -n 'pid$1:::entry { @[probefunc] = count(); }' `top -b | head -10 | tail -1 | chomp | cut -w -f1`
