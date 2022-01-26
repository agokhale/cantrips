#include <stdio.h>
#include <strings.h>

int main ( int argc, char ** argv ){
unsigned int histo[256];
int ic = 66;

explicit_bzero (histo, 256); 

for (int i=0; i<256 ; i++ ){ histo[i]=0;}
	do {
	ic = getchar();
	if ( ic > 0 )
		histo[ic] ++; 
	//putchar (ic);
	} while ( ic > 0);

for (unsigned int i=0; i<256; i++) {
	if (histo[i]> 0) { 
		printf( "%u\t%u\n",i, histo[i]);
		};
	}

}
