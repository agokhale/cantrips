all:
	cc -g -o viamillipede -lpthread  plumbing.c rx.c tx.c viamillipede.c
clean: 
	rm -f viamillipede

test: clean all
	sh -x test.sh

payload:
	dd if=/dev/random of=rand.payload bs=512k count=4
	dd if=/dev/random of=rand4.payload bs=1m count=4
	dd if=/dev/random of=rand10.payload bs=1m count=10
	dd if=/dev/random of=rand1.payload bs=1m count=1
	dd if=/dev/random of=rand100.payload bs=1m count=100
server : 
	./viamillipede rx 12323  verbose 19 > out.payload
client:
	./viamillipede tx localhost  12323 verbose 19  < rand.payload
