#!/bin/sh -e
git status | awk '/Untracked/ { latch=1;} /\t/ { if(latch == 1) {print ($0);}}'
