#!/bin/sh -xe
find . -newermt "Nov 10, 2020 23:59:59" -type dir -depth 2 | \
	shuffle -f - | \
	tail -309 | \
	sort 
