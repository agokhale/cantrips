#!/bin/sh -xe
# use witch xargs to collide all the repos: 
# cat repos | xargs -I % -n1 ./collide.sh %
repo=$1
git subtree add --prefix $repo "git@github.com:bulldog-dev/${repo}"  stage
