#include <stdio.h>
#include <strings.h>
#include <stdlib.h>



int main ( int argc, char ** argv ){
int ic = 66;


	do {
     ic = 0; 
	  ic = getchar();
     //ic &= 0x7f;
	  putchar (ic - 110);
	} while ( ic >= 0);

}
