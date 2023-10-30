#!/bin/sh 
set -xe
#from https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28
UrL="https://api.github.com/orgs/${GIThubORG}/${repo}"
curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${ASH_GITOK}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
	${1}
