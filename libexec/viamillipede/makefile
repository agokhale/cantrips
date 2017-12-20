all:
	cc -g -o viamillipede -lpthread  plumbing.c rx.c tx.c viamillipede.c
clean: 
	rm -f viamillipede

test: clean all
	sh -x test.sh

payload:
	dd if=/dev/random of=rand.payload bs=1m count=103
server : 
	./viamillipede rx 12323  verbose 19 > out.payload
client:
	./viamillipede tx localhost  12323 verbose 19  < rand.payload
