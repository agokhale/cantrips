#!/bin/sh 
set -x 
set -e

script_full_path=`realpath $1`
pushd $2
$script_full_path
popd
