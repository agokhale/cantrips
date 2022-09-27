no:
	echo no 
up: 
	git pull
install:
	install -m 655 cshrc ${HOME}/.cshrc
	install -m 555 howto/linux/vimrc  ${HOME}/.vimrc
histo:
	cc -o libexec/histo libexec/histo.c
