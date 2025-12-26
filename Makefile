no:
	echo no 
up: 
	git pull
install: bin
	install -m 655 cshrc ${HOME}/.cshrc
	install -m 555 howto/linux/vimrc  ${HOME}/.vimrc
bin: histo 0b bitfilter
histo:
	cc -o ${HOME}/bin/histo libexec/histo.c
0b:
	cc -o ${HOME}/bin/0b_to_bin libexec/0b_to_bin.c
	echo -n '0101010110101010' | ${HOME}/bin/0b_to_bin | hd
bitfilter:
	cc -o ${HOME}/bin/bitfilter libexec/bitfilter.c
	echo -n '0101010110101010' |  ${HOME}/bin/0b_to_bin | ${HOME}/bin/bitfilter | hd
