#!/bin/sh
dtrace -ln ':::' | awk '// { print ($2":"$3":"$4":"$5" ");}'

