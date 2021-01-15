#!/bin/sh -x

$* 2>&1 |  sed -e 's/[\d128-\d255\d010]//g' 
