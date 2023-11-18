#!/bin/sh -e
git status | awk '/not staged/ {lat=1;} /Untracked/ {lat=0} /modi/{if (lat) print ($2)} /new file:/ { print($3);} '
