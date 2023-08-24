#!/bin/sh -e 
#https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories

UrL=${1}

curl -s -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${ASH_GITOK}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  ${UrL}



#git_branchesjson.sh "https://api.github.com/repos/<xxxxxxfrom git_repogetjosn>/branches" | jq .[].name 


