complete xpdf 'p/1/`echo *.pdf `/'
#this inner qouting is silly
complete FreeCAD	'p/1/`find . -regex \^\.\*\\.FCStd\$`/'
complete prusa-slicer	'p/1/`find . -regex \^\.\*\\.3mf\$`/'

complete usbconfig 'p/1/(-d )/'  'p/2/`usbconfig | cut -d:  -f1 `/' 'p/3/( set_config set_alt set_template get_template detach_kernel_driver dump_quirk_names dump_device_quirks dump_all_desc dump_device_desc dump_curr_config_desc dump_all_config_desc dump_string  dump_info dump_stats show_ifdrv suspend resume power_off power_save power_on reset list do_request )/'

  alias gitreallybranchpush 'git push origin \!\!:1 && git branch --set-upstream-to=origin/\!\!:1 \!\!:1'
complete gitreallybranchpush 'p/1/`git branch `/'

   # based on https://github.com/cobber/git-tools/blob/master/tcsh/completions
alias _gitobjs 'git branch -ar | sed -e "s:origin/::";  git tag; ls'
alias _gitcommitish 'git rev-list --all '
set gitcmds=(add bisect blame branch checkout config   cherry-pick clean clone commit describe difftool fetch grep help init \
                        log ls-files mergetool mv pull push rebase remote rm show show-branch status submodule tag)

complete git          "p/1/(${gitcmds})/" \
                        'n/branch/`git branch -a`/' \
                        'n/checkout/`_gitobjs`/' \
                        'n/clean/(-dXn -dXf)/' \
                        'n/diff/`_gitobjs`/' \
                        'n/fetch/`git branch -r`/' \
                        "n/help/(${gitcmds})/" \
                        'n/init/( --bare --template= )/' \
                        'n/merge/`_gitobjs`/' \
                        'n/push/( origin `git branch -a`)/' \
                        'N/remote/`git branch -r`/' \
                        'n/remote/( show add rm prune update )/' \
                        'n/show-branch/`git branch -a`/' \
                        'n/stash/( apply branch clear drop list pop show )/' \
                        'n/submodule/( add foreach init status summary sync update )/' \
                        'n/add/`_gitstatusuntracked.sh `/' \
                        'n/clone/( git@github.com:agokhale/ )' \
                        'n/commit/`_gitcommitable.sh `/'

