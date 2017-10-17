#!/bin/sh
dtrace -n 'pid$1:::entry { @[probefunc] = count(); }' `ps -auxw | awk  '/^/  {print ($3,$2, $0);}' | sort -n | tail -2 | head -1 | awk  '/^/ { print ($2);}'`
