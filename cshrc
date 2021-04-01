set ashrcversion = "10.3.2"
# "$Id: cshrc,v 1.64 2017/07/21 19:20:48 xpi Exp $"
# 1999 - 2017 Ash
# BSD license
# General disclaimer about damages real or causal resulting in teh use of this
#"software"
#___________________________________core paths_________________________________
set notify
#allow local paths to override  global ones
if ( -f /etc/skel/.chsrc ) then
	source /etc/skel/.cshrc	
endif #etcskel

#path_roots are possible stems for path heirarchy. 
#  taken from various unix traditions
# perform discovery for places to put executables, libraries and man pages
# **can't use * in path_roots expansion or set bombs if there are no children 
#   ex: /usr/local/* ; found on freebsd, new install
# this tasting process may be expensive on certain platforms where negative file
#   tests are slow

set path_roots = ( $HOME / /opt /usr/ucb /usr /usr/local )
set path_roots = ( $path_roots /opt/local /usr/share /sw /opt/X11 /usr/X11 )   
#path_components are places to look for binaries inside path_roots
set path_components = ( bin sbin libexec games tools ) 

#mosh-client needs a UTF-8 native locale to ruh-client needs a UTF-8 native locale to run.
#setenv LC_ALL en_US.UTF-8.

#start with minimal paths so we have a path should things short out during launch
setenv MANPATH /usr/share/man:/usr/local/man
setenv PATH /bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
setenv PATH ${PATH}:${HOME}/cantrips/libexec:${HOME}/cantrips/dt:${HOME}/bin

#now find more path_roots; 
#possibly expensive workaround for /usr/local/* in path_roots
#foreach pathroot_candidate ( `ls /usr/local `) 
#	if ( -d /usr/local/$pathroot_candidate )  then
#		#echo $pathroot_candidate is a dir
#		set path_roots = ( $path_roots /usr/local/$pathroot_candidate )
#	endif #is a directory
#end #foreach pathroot_candidates
#hunting through local might net you a cross compiler, don;t

#let cygwin off the hook for expensive fs/stat/hash stuff
if ( ${OSTYPE} == "cygwin" ) then
        set pathroot_candidates = " "
        set path_roots = "/usr/i686-pc-cygwin/ "
	setenv PATH /cygdrive/c/Windows/System32/:${PATH}
endif

if (   $?VIRTUAL_ENV ) then 
	setenv PATH ${VIRTUAL_ENV}/bin:${PATH}
endif
	

foreach pathroot ( $path_roots )
    if ( -d $pathroot/man ) then
        if ( $MANPATH =~ "*$pathroot/man*" ) then 
            #echo "found redundant man $pathroot"
        else
            #echo found man $pathroot
            setenv MANPATH "$pathroot/man":$MANPATH
        endif
    endif

     if ( -d $pathroot/share/man ) then
        if ( $MANPATH =~ "*$pathroot/share/man*" ) then 
            #echo "found redundant man $pathroot/share"
        else
            #echo found man $pathroot/share
            setenv MANPATH "$pathroot/share/man":$MANPATH
        endif
        
    endif
    #look for locations of binaries within a pathroot 
    foreach pathcomponent ( $path_components ) 
        if ( -d $pathroot/$pathcomponent ) then
               if ( $PATH =~ "*$pathroot/$pathcomponent*" ) then 
                    #echo "found $pathroot/$pathcomponent redundant"
                else
                    #echo "$pathroot/$pathcomponent found"
                    #setenv PATH "$pathroot/$pathcomponent":$PATH
                endif
        endif #$pathcomponent exists
    end #foreach pathcomponent
end # foreach pathroot

setenv gUNAME `uname` #must be global
if ( $?prompt ) then
#______________________________________________________interactive 
	setenv gTODAY `date +"%Y%m%d"`
	alias gTODAY  'setenv gTODAY  `date +"%Y%m%d"`; echo ${gTODAY}'
	alias rt 	'sudo tcsh'
	alias gNOW  'setenv gNOW  `date +"%s"`; echo ${gNOW}'
	alias space2tab "sed -E 's/ +/	/g'" #that's a hard tab in that hole
	alias prbsgen 'viamillipede verbose 5 tx localhost 12345 rx 12345 prbs 0xd00f leglimit \!\!:1 threads 4'
	alias prbsvrfy ' vimillipede tx localhost 12346 threads 4 & viamillipede verbose 5 rx 12346 prbs 0xd00f > /dev/null  '

	alias chomp "sed -E 's/^ +//'"  #strip leading space
	alias usage  "du -sxk * | sort -rn > usage; less usage"
	alias xrange 'python -c "for i in xrange (\!\!:1,\!\!:2):  print i" '
	alias byte 'python -c "import sys; sys.stdout.write (chr(\!\!:1))"'
	alias ess	'\!-1 | less'
	alias p[        pushd
	alias p]        popd
	alias p[]       "dirs -v"
	alias p		"ps -axwww | grep -v grep | grep " #put the pid in the first column
	setenv REDSIG	2
	setenv REDCOL	1
	alias redpids  "sed -E 's/^ +//' | sed -E 's/ +/	/g' | cut -f${REDCOL} " 
	alias redtide  "redpids | xargs -n1 kill"

	alias srx 's \!\!:1 "cd \!\!:2 ; tar -cf - \!\!:3-$ " | tar -xpf -' 
	alias stx 'tar -cf - \!\!:3-$  | s \!\!:1 "cd \!\!:2 ; tar -xpf - "' 
	alias r 's -x -l root'
	alias R 's -x  -Y -l root'
	alias s 'ssh -Y '
	alias S 's '
	alias l 'source ~/.cshrc'	
	alias vl 'vi ~/.cshrc'
	alias vll 'vi ~/.cshrc.local'
	alias ve 'vi +$'
	alias vimsg 'v +$ /var/log/messages'

	#set hunthome=${PWD}
	alias hunting_ground 'set hunthome=`pwd`'
	#find a zymbol
	alias hunt 'echo $hunthome; grep -nR \!\!:1 $hunthome |& grep -v "No such file or" | grep -v ": Permission denied" | grep -v "Operation not supported"'
	#transform  file:linenum: into vi $1 +$2
	alias jump '`hunt \!\!:1 \!\!:2 | space2tab | cut -f1 | uniq |  viize`'
	#go edit file with symbol $1 in filename matching $2
	alias viize "sed -E 's/^(.*):([0-9]*):/vi \1  +\2/'"    
	set listjobs="long"
	set autologout="0  1"
	set promptchars="#&"
	set rprompt=":%B`whoami`%b:%c5:%P:%\!%S%m%s"
	set complete="enhance"
	set matchbeep="never"

	set hosts=(`awk '/^[0-9].*/ {sub("#.*","",$0); print ($0, "\n");}  NR==254  { print (NR,"truncated");exit(0)}' /etc/hosts`)
	if ( -f ${HOME}/.ssh/known_hosts ) then
		set hostskn=(`awk '// {gsub ("[\\[\\]]","",$1); print ($1,"\n")}    NR==254  { print (NR,"truncated");exit(0)} ' ${HOME}/.ssh/known_hosts `)
		set hosts=($hosts $hostskn)
	endif
	if ( -f ${HOME}/.ssh/config ) then
		set hosts=($hosts `awk '/Host/ {print $2}    NR==264  { print (NR,"truncated");exit(0)}' ${HOME}/.ssh/config`)
	endif
    # populate multiple idents for ssh -i 
	
	complete gstat 'p/1/(-f)/' 'p/2/(da)/' 'p/3/(-p)/'
	complete viamillipede 'p/1/(tx rx verbose threads prbs)/'  'n/tx/$hosts/' 'N/tx/( 1234 )/' \
               'n/rx/( 1234 )/' 'n/verbose/( 4 )/' 'n/prbs/( 0xdead )/' 'N/verbose/( threads )/' \
               'n/threads/( 4 )/'  'N/threads/( tx )/'
	complete aws 'n/ec2/`aws ec2 wat |& grep e`/' 'p/1/(ec2 s3 configure)/'  'n/terminate-instances/(--instance-ids )/' \
		'n/--instance-ids/`awsinstanceids.sh`/' \
		'n/stop-instances/(--instance-ids )/' \
		'n/start-instances/(--instance-ids )/'  
   	complete systat 'p/1/(-ifstat -vmstat -iostat)/' 
	complete su  'p/1/-u/'
	complete fg           'c/%/j/' #per wb
	complete sudo  'p/1/( tcsh bash port fink )/'
	complete r 'p/1/$hosts/'
	complete s 'p/1/$hosts/'
	complete sftp 'p/1/$hosts/'
	complete S 'p/1/$hosts/'
	complete R 'p/1/$hosts/'
	complete p 'p/1/`p . | space2tab | cut -f1,4 `/'
	complete S 'p/1/$hosts/'
	complete cvs 'p/1/(  status commit checkout )/' 
	complete ping  'p/*/$hosts/' 
	complete dig 'p/*/$hosts/' 
	complete ssh  'c/*@/$hosts/' 'p/1/u/@'
	# simple push scp
	complete scp  'p/1/( -r )/'  \
			'p/2/`ls  `/' \
                        'p/3/$hosts/'
	alias __maketargets 'getmaketargets.awk *akefile'
	complete make 'p/1/`__maketargets`/'
	complete man 'p/1/c/'
	complete which 'p/1/c/'
	complete where 'p/1/c/'
	complete cdrecord 'p/1/(dev=3,0,0<see_camcontrol_devlist>)/' 'p/2/f/'
	#pkg wb

if ( ${gUNAME} == "FreeBSD" ) then
	set pkgcmds=(help add annotate audit autoremove backup check clean convert create delete fetch info install lock plugins \
                        query register repo rquery search set shell shlib stats unlock update updating upgrade version which)
	alias pkgsch	'set pkgtgt=`pkg search \!\!:1 | cut  -w -f1`; echo $pkgtgt' 
	alias pkgsch	'set pkgtgt=`pkg search "-" | cut  -w -f1`; echo $pkgtgt' 
	

	alias __pkgs  'pkg info -q'
	# aliases that show lists of possible completions including both package names and options
	alias __pkg-check-opts        '__pkgs | xargs echo -B -d -s -r -y -v -n -a -i g x'
	alias __pkg-del-opts          '__pkgs | xargs echo -a -D -f -g -i -n -q -R -x -y'
	alias __pkg-info-opts         '__pkgs | xargs echo -a -A -f -R -e -D -g -i -x -d -r -k -l -b -B -s -q -O -E -o -p -F'
	alias __pkg-which-opts        '__pkgs | xargs echo -q -o -g'

	complete pkg          'p/1/$pkgcmds/' \
			'n/check/`__pkg-check-opts`/' \
			'N/check/`__pkgs`/' \
			'n/delete/`__pkg-del-opts`/' \
			'N/delete/`__pkgs`/' \
			'n/help/$pkgcmds/' \
			'n/info/`__pkg-info-opts`/' \
			'N/info/`__pkgs`/' \
			'n/which/`__pkg-which-opts`/' \
			'N/which/`__pkgs`/' \
			'n/install/`pkgsch`/'

#endif #freebsd
	alias gitreallybranchpush 'git checkout -b \!\!:1 && git push origin \!\!:1 && git branch --set-upstream-to=origin/\!\!:1 \!\!:1'

	 # based on https://github.com/cobber/git-tools/blob/master/tcsh/completions
	alias _gitobjs 'git branch -ar | sed -e "s:origin/::"; ls'
	alias _gitcommitish 'git rev-list --all '
  set gitcmds=(add bisect blame branch checkout cherry-pick clean clone commit describe difftool fetch grep help init \
                        log ls-files mergetool mv pull push rebase remote rm show show-branch status submodule tag)

	complete git          "p/1/(${gitcmds})/" \
                        'n/branch/`git branch -a`/' \
                        'n/checkout/`_gitobjs`/' \
                        'n/clean/(-dXn -dXf)/' \
                        'n/diff/`_gitobjs`/' \
                        'n/fetch/`git branch -r`/' \
                        "n/help/(${gitcmds})/" \
                        'n/init/( --bare --template= )/' \
                        'n/merge/`git-list all branches tags`/' \
                        'n/push/( origin `git branch -a`)/' \
                        'N/remote/`git branch -r`/' \
                        'n/remote/( show add rm prune update )/' \
                        'n/show-branch/`git branch -a`/' \
                        'n/stash/( apply branch clear drop list pop show )/' \
                        'n/submodule/( add foreach init status summary sync update )/'
			

	complete find 'n/-name/f/' 'n/-newer/f/' 'n/-{,n}cpio/f/' \
       'n/-exec/c/' 'n/-ok/c/' 'n/-user/u/' 'n/-group/g/' \
       'n/-fstype/(nfs 4.2)/' 'n/-type/(b c d f l p s)/' \
       'c/-/(name newer cpio ncpio exec ok user group fstype type atime \
       ctime depth inum ls mtime nogroup nouser perm print prune \
       size xdev)/' \
       'p/*/d/'	
	alias finddaterange 'find log/ -newermt "Nov 10, 2020 23:59:59" ! -newermt "Nov 26, 2020 23:59:59"'

	#zfs
	complete zfs 'p/1/(get set list destroy snapshot create clone promote send recv hold )/' \
		'n/list/`zfs list -t all | cut -w -f1`/' \
		'n/destroy/`zfs list -t all   | cut -w -f1`/' \
		'n/send/`zfs list -t all | cut -w -f1`/' \
		'n/snapshot/`zfs list | cut -w -f1`/' \
		'n/promote/`zfs list -t all  | cut -w -f1`/' \
		'n/get/`zfs get all  | cut -w -f2 | sort | uniq`/' \
		'n/set/`zfs get all  | cut -w -f2 | sort | uniq`/=' 'N/set/`zfs list | cut -w -f1`/' \
	
  set _npmcmds=(ci install run)
  alias _npmruntargets 'cat package.json | jq ".scripts | keys"' 
  complete npm  "p/1/(${_npmcmds})/" \
      'n/run/`_npmruntargets`/'
  
	# groups
	complete chgrp 'p/1/g/'
	# users
	complete chown 'p/1/u/' 
	complete setenv 'p/1/e/'
	complete unsetenv 'p/1/e/'
	complete set 'p/1/s/='
	complete uncomplete 'p/*/X/'
	complete dd           'c/if=/f/' 'c/of=/f/' \
                        'c/conv=*,/(ascii block ebcdic lcase pareven noerror notrunc osync sparse swab sync unblock)/,' \
                        'c/conv=/(ascii block ebcdic lcase pareven noerror notrunc osync sparse swab sync unblock)/,' \
                        'p/*/(bs cbs count files fillcahr ibs if iseek obs of oseek seek skip conv)/='

	complete cd 'C/*/d/'
	complete kill 'c/-/S/' 'c/%/j/' 
	set tdterms = (proto tcp udp icmp ether fddi ip arp ip6 dir src dst inbound outbound port  portrange less greatergateway net and or host src dst broadcast multicast atalk ipx decnet on rulenum reason rset subrulenum action vlan mpls ppoed iso vpi  lane llc oam4s link slip icmp-echoreply icmp-unreach icmp-sourcequench  icmp-redirect icmp-echo icmp-routeradvert icmp-routersolicit icmp-timxceed icmp-paramprob icmp-tstamp icmp-tstam-preply icmp-ireq icmp-ireqreply icmp-maskreq icmp-maskreply tcp-fin tcp-syn tcp-rst tcp-push tcp-ack tcp-urg )
	alias  td "sudo tcpdump -lvvnX -s200  -i "
	complete td  'p/1/$interfaces/' 'p/*/$tdterms/'
	alias tdtrace 'echo "interface \!\!:1 file: \!\!:2 expression: \!\!:3-$";              sudo tcpdump -s0 -i \!\!:1 -C 24 -W 10 -w \!\!:2`date +"%s"`.\!\!:1.pcap                                \!\!:3-$'
	alias fixcshrc 'wget "https://github.com/agokhale/cantrips/archive/master.zip"'
	complete tdtrace 'p/1/$interfaces/' 'p/2/(pcapfile inny outty foo)/' 'p/*/$tdterms/'
	complete netstat 'p/1/(-m -an -i -Tn -xn -Q )/' 'p/2/(-finet)/' 
	alias screenlet 'screen -S `echo \!\!:1 | cut -w -f1  ` -dm \!\!:1' 
	complete screenlet 'p/1/c/' #commands for screenlet
	alias sc 'screen -c ${HOME}/cantrips/env/screenrc'
	alias _screenparts 'screen -ls | grep  tached | cut -f2 | cut -f2 -d.; screen -ls | grep tached | cut -f2'
	complete sc 'p/1/(-dr) S /' 'p/2/`_screenparts`/' 
	alias cs 'cscope -R'
	alias  td 'tcpdump  -n'
	complete td 'p/1/( -i )/'  'p/*/( -v -x -X -wfile -rfile -s00 )/'
	complete dc 'p/1/(-e)/' 'n/-e/(16o16iDEADp 2p32^p)/' 
	set dtraceprobes=( 'syscall:::entry' 'tick-3s' )
 	alias dtrace_update_probes '${HOME}/cantrips/libexec/dtraceprobes.sh > /tmp/dtrace.probes'
	complete dtrace 'p/1/(-n -s -p -v -l)/'  'n/pid/p/'  'n/-o/f/' 'n/-p/p/'  'p/1/-s'
	complete sysctl 'n/*/`sysctl -aN`/'
	complete kldload 'p|1|`ls /boot/modules /boot/kernel `|' #use | as a delimeter to deconflict /path
	complete umount 'p^1^`mount | cut -w -f3`^'
	complete cu 'p/1/( -l )/' 'n^-l^`ls /dev/{cu,tty}*[0-9]*`^' 'n/-s/( 9600 115200 38400 )/'
	set dunique
	set colorcat
	set prompt2="loop%R>"
	set prompt3="willis?   %R   >"
	setenv EDITOR `which vi`
	set autolist
	set printexitvalue
	#if something takes 1 sec - find out how long. 
	set time=(1 "user:%U system:%S wall:%E cpu:%P%% shared:%X+private:%DkB  input:%I output:%O faultsin:%F swaps:%W")
	#unset color
	#unsetenv LS_COLOR
	set listflags="XaA"
	alias v 	view
	alias ssh-initagent 'mkdir -v -m 700 -p ${HOME}/.tmp/; ssh-agent -c > ${HOME}/.tmp/ssh-agent.csh; source  ${HOME}/.tmp/ssh-agent.csh'
	alias keydsa 		'cat ~/.ssh/id_*sa.pub  | ssh \!\!:1 "mkdir -p .ssh; chmod 700 .ssh; cat - >> .ssh/authorized_keys ; chmod 600 .ssh/authorized_keys"'
	complete keydsa  'p/1/$hosts/'
	alias keydrop 'echo "keydropping ssh key (two seconds to abort)" ; grep "^\!\!:1" ~/.ssh/known_hosts || echo "did you mean this one?:"; grep \!\!:1 ~/.ssh/known_hosts ; sleep 1; echo "."; sleep 1; cp ~/.ssh/known_hosts /tmp/; cat ~/.ssh/known_hosts | sed -e "/^\!\!:1/d" > /tmp/keytmp && cp /tmp/keytmp ~/.ssh/known_hosts'
	complete keydrop 'p/1/$hosts/'
	if ( -f ${HOME}/.tmp/ssh-agent.csh ) then
		source ${HOME}/.tmp/ssh-agent.csh >  /dev/null
		#if there is actually a control socket read the keylist
		if ( -f $SSH_AUTH_SOCK ) then
			set ssh_agent_report=`ssh-add -l `
		endif
	endif
	set vag_topcommands = ( autocomplete box        cloud     destroy  global-status halt         help        init       \
		login     package  plugin  port   powershell  provision  push      rdp      reload  resume  \
		snapshot ssh     ssh-config status   suspend up     upload validate version winrm  winrm-config )
	complete vagrant 'p/1/$vag_topcommands/'
	complete salt-call 'p/1/(state.apply)/'
	
	alias df	df -k
	alias du	du -xk
	alias h		'history -r | more'
	alias wipe	'echo -n  > '
	alias hide 	'mkdir -p .hidden; mv \!\!:1 .hidden/\!\!:1\-`date +"%s"`'
	alias checkpoint 	'mkdir -p .hidden; cp \!\!:1 .hidden/\!\!:1\-`date +"%s"`'
	alias lf	ls -FA
	alias ll	ls -lgsArtF
	alias lr	ls -lgsAFR
	alias tset	'set noglob histchars=""; eval `\tset -s \!*`; unset noglob histchars'
	alias mc  'mc -b' #no color please
	alias random_playback 'find . -type f -name "*.mp3" -print0 | sort -zR | xargs -L1 -I% -0 mplayer -ao oss:/dev/dsp1 "%"'

	set nobeep
	set correct = cmd
	set nostat="/afs /.a /proc /.amd /.automount /net"
	set fignore=( .o .a .bak ~ , .v .bad .old .syms .dylib .lst .ld .so .org .virg. .tmp .pyc .oo .al .exe .dll .obj . .1 .svn CVS )
	set symlinks=expand
	#set filec ##// tcsh implicit complettion 
	set nokanji
	set histdup erase
	#set implicitcd=verbose
	#set savedirs  ##/annoying rentrant behaviours
	set listmax = 120
	set history = 1000
	set ignoreeof = 5
	umask 22
	#version
	set	dcmesg = ".cshrc> $ashrcversion ${gUNAME} "
	# make help/ins key do something useful for a change, the loafy
	bindkey -c ^[[2~ 'setenv eetmp `date +"%s"`.tcshtmp;  history > /tmp/${eetmp}; vi /tmp/${eetmp}'
	#f13
	bindkey ^[[25~ vi-search-back
	#f12
	bindkey ^[[24~ complete-word-back
	#f11
	bindkey ^[[23~ complete-word-fwd
	#f10
	bindkey ^[[21~ delete-word
	#f9
	bindkey ^[[20~ backward-delete-word
	#f8
	bindkey ^[[19~ forward-word
    #mac opt ->
	bindkey ^]f backward-word
	#f7
	bindkey ^[[18~ backward-word
	#f6
	bindkey ^[[17~ vi-search-back
    #mac opt <-
	bindkey ^[b backward-word
	#f2
	bindkey -c ^[OQ 'date +"%s - %+ " >> ~/lerg;  cat ${HOME}/.tmp/cltmp >> ~/lerg; vi +$ ~/lerg' 
	#f1  edit last command line
	bindkey -c ^[OP 'history > $HOME/.tmp/cledittmp; vi $HOME/.tmp/cledittmp'

	#smart up key
	bindkey -k up history-search-backward
	bindkey -k down history-search-forward
	
	if (  ${?TERM} & ${TERM} =~ "xterm*" || ${TERM} == "screen"  ) then
		setenv Xgreenscreenopts '-bg black -fg green'
		alias xterm xterm  ${Xgreenscreenopts}
		set betterfont40="-*-courier-*-r-*-*-40-*-*-*-*-*-*-*"
		set betterfont20="-*-courier-*-r-*-*-20-*-*-*-*-*-*-*"
		set betterfont30="-*-courier-*-r-*-*-30-*-*-*-*-*-*-*"
		set betterfont10="-*-courier-*-r-*-*-10-*-*-*-*-*-*-*"
		set betterfont8="-*-courier-*-r-*-*-8-*-*-*-*-*-*-*"
		set betterfont="-*-courier-*-r-*-*-12-*-*-*-*-*-*-*"
		alias xt 'xterm -u8  ${Xgreenscreenopts}  &'
		alias xt8 'xterm ${Xgreenscreenopts} \\
			-fn "$betterfont8" &'
		alias xt20 'xterm -bg black -fg green -fn \\
			"$betterfont20" &'
		alias xt30 'xterm -bg black -fg green -fn \\
			"$betterfont30" &'
		alias xt40 'xterm -bg black -fg green -fn \\
			"$betterfont40" &'
		#if ( $USER == "root" ) then 
			#printf "\b\n\033[31m\033[43m thou art root\n"
		#else
			#https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
			#printf "\b\n\033[35m prp \033[91;40m 000  \n" #purple
			#set rprompt=":`whoami | cut -c 1-4`:%c2:%P:%m"
			#colorswatch 
			#foreach i ( `jot 49` )
			#	 printf "\b\n\033[%sm %s" "$i" "$i"
			#end
		#endif
		alias beepcmd 'printf "\033[35mbeep?\033[39;49m\b\b\b\b\b"'
	endif #xterm specializations

endif #prompt


#________________________________________________________________
if ( ${gUNAME} == "Linux" ) then
setenv REDCOL 1  #why is ps a mercurial flower?
if ( $?prompt ) then
	unalias ls
	unalias vi
	alias p		"ps -efwww | grep -v grep | grep "
	alias aptimemo 'echo memoinstall \!\!:1; sleep 2; apt install -y \!\!:1 && echo \!\!:1 >> ~/memo_apt_list ; tail apt_list'
	complete p 'p/1/`ps -efwww | cut -b39-120 `/'
	complete kill 'c/-/S/' 'c/%/j/' 'p/1/`ps -ef | cut -b10-15 `/'
	alias monstar	'tail -f /var/log/messages &;\
		 tail -f /var/log/daemon &; \
		 tail -f /var/log/syslog & '

endif #prompt
endif
#________________________________________________________________
if ( ${gUNAME} == "Darwin" ) then
setenv MANPATH /sw/share/man/:$MANPATH
setenv PAGER `which less`
if ( $?prompt ) then
	complete redtide 'p/1/`ps -axwww`/'
endif #prompt
endif #darwin
#________________________________________________________________
if ( ${gUNAME} == "FreeBSD" ) then
	alias monstar 'tail -F /var/log/{messages,auth.log,mail.log}'
	setenv REDCOL 0  #why is ps a mercurial flower?
	complete redtide 'p/1/`ps -auxwww`/'
	if ( -f /etc/csh.chsrc ) then
		source /etc/csh.cshrc	
	endif #etcskel
	complete service 'p/1/`service -l`/' 'p/2/( start  stop restart rcvar enabled status poll)/'
endif #freebsd
#________________________________________________________________
if ( ${gUNAME} == "SunOS" ) then
	if ( $?prompt ) then
		#echo "SunOS environment - Illuminos?"
	endif #prompt 
	alias monstar	'tail -f /var/adm/messages &;\
			tail -f /var/log/syslog & '
	alias ps        /usr/ucb/ps
	setenv EDITOR /usr/ucb/vi
	setenv PATH /usr/ucb:${PATH} #replace stupid sun tools with BSDisms 
	setenv PATH ${PATH}:/usr/ccs/bin #base compiler and bintools
	setenv PATH ${PATH}:/usr/opt/SUNWmd/sbin #for raid tools
	setenv PATH ${PATH}:/usr/platform/sun4u/sbin #for prtdiag

endif ##sunos


setenv CVS_RSH	`which ssh`
setenv RSYNC_RSH `which ssh`	 
setenv RSH `which ssh`	 #for rdist
#________________________________________________________the last word locally
#makes all things here mutable
#let the local thing mutate  my nice presets
if ( -r ${HOME}/.cshrc.local ) then
	source ${HOME}/.cshrc.local
endif 

#BitchX
setenv IRCNICK nopenpoe
setenv IRCNAME  "user is much too lame "
setenv IRCSERVER  irc.freenode.net
