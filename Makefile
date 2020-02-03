no:
	echo no 
up: 
	git pull
install:
	install -m 755 cshrc ${HOME}/.cshrc
