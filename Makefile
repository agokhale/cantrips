no:
	echo no 
up: 
	git pull
install:
	install -m 655 cshrc ${HOME}/.cshrc
	install -m 555 howto/linux/vimrc  ${HOME}/.vimrc
histo:
	cc -o libexec/histo libexec/histo.c
0b:
	cc -o libexec/0b_to_bin libexec/0b_to_bin.c
	echo -n '0101010110101010' | libexec/0b_to_bin | hd
