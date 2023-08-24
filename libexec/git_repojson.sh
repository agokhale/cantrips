#!/bin/sh -e 
#https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories

UrL="https://api.github.com/orgs/${GIThubORG}/repos"

curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${ASH_GITOK}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  ${UrL}




#ls_gitrepos.sh | jq -c -r '(.[] | (.id, .html_url, .ssh_url)), "# of repos",length' | grep '^git@' | xargs -n 1 git clone 
##heat 
# git_repojson.sh | jq -r '.[]| (.pushed_at + "    " + .ssh_url)' | sort -rn 
#$$branch urls for jbranchjson
#[peaseblossom:~/tmp/clonesplat] xpi# git_repojson.sh | jq '.[].branches_url ' | sed -e 's+{/branch}++'

