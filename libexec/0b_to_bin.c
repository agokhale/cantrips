#include <stdio.h>
#include <strings.h>
#include <stdlib.h>


void accumulate_if_1 (int *acc, int testchar,  int pos) {
	if (testchar =='1') {
	  *acc  |=  1<<pos;	
	} else if ( testchar == '0') {

	} else if ( testchar < 0 ) {
		//exit(0);
   } else {
		printf("frame error"); 
		exit (44); 
	}
}

int main ( int argc, char ** argv ){
int ic = 66;
int acc=1;
int bcursor =7;


	do {
	acc =0;
   bcursor =7;
	while (bcursor >=0 ) {
			  ic = getchar();
			  accumulate_if_1 ( &acc, ic, bcursor--);	
			  }

	putchar (acc);

	} while ( ic >= 0);

}
