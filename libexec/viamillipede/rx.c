#include "worker.h"

void rxworker ( struct rxworker_s * rxworker ) {
	int done =0; 
	int readsize;
	int readlen;  // XXX 
	char * buffer;
	char  okphrase[] ="ok";
	char  checkphrase[] ="yoes";
	u_char   rxpreamble_in [2]; 
	u_char   rxpreamble_cannon [] = { 0xa5, 0x5a}; 
	int rxbuffersize; 
	int rxbufferleg; 
	buffer = calloc ( 1 , (size_t)kfootsize );
	whisper ( 8, "   rx worker  connected id%i fd:%i\n", rxworker->id, rxworker->fd); 
	read ( rxworker->fd , buffer, (size_t)  4 ); //XXX this is vulnerable to slow starts
	if ( bcmp ( buffer, checkphrase, 4 ) == 0 ) 
		{ whisper ( 8, "checkphrase ok\n"); } 
	else 
		{ assert (-1 && "checkphrase failure "); }	
	checkperror (" nuiscance ");
	assert ( write (rxworker->fd, okphrase, (size_t)  2 ) && "sigwritefail");
	checkperror ( "signaturewrite "); 
	// /usr/src/contrib/netcat has a nice pipe input routine
	while ( ! done) {
		readlen = read ( rxworker->fd , rxpreamble_in, 2 );  // XXX this shuold all be XDR/protocol 
		//XXXX way too hot
		whisper ( 19 ,"rxw:%i preamble: %i\n", rxworker->id, readlen); 
		// this is where we expect to die when eof comes for us; or the line idles
		//assert ( readlen == 2 && "preamble read failure"); 
		// so dont' assert 
		if ( readlen < 0 ) {
			assert (readlen  && " bad preamble read, are we done now?");
		}
		if ( readlen == 0 ) { 	
			//usleep ( 100);  //XXXX
			whisper ( 6, "rxw:%i last_leg:%i exits after empty preable", rxworker->id, rxbufferleg); 
			pthread_exit( rxworker );  // no really we are done, and who wants our exit status?
			continue;
		}; 
		
		assert ( bcmp ( rxpreamble_in, rxpreamble_cannon, 2) == 0  && "preamble check");
		readlen = read ( rxworker->fd , &rxbuffersize , sizeof (int) ); 
		assert ( readlen == sizeof(int)); 
		if ( rxbuffersize < 1 )  {
			whisper ( 3, "rxw:%i fishy rxbuffersize:%i  readlen:%iare we done?\n",
				rxworker->id, rxbuffersize,readlen);
		}
		assert ( rxbuffersize >= 0 ); 
		assert ( rxbuffersize <= kfootsize); 
		assert ( rxbuffersize >  0);  
		readlen = read ( rxworker->fd , &rxbufferleg , sizeof(int) ); 
		assert ( readlen = sizeof(int)); 
		assert ( rxbufferleg >= 0 ); 
		whisper ( 9, "wrk:%i leg:%i siz:%i caught new leg  \n", rxworker->id,  rxbufferleg , rxbuffersize); 
		int remainder = rxbuffersize; 
		assert ( remainder <= kfootsize); 
		int cursor = 0; 
		while (  remainder && !done  ) {
			readsize = read ( rxworker->fd, buffer+cursor, MIN(remainder, MAXBSIZE )); 
			cursor += readsize; 
			remainder -= readsize ; 
			assert ( readsize > 0 );  //XXX 
			if (readsize == 0) { //XXXXXXXX 
				whisper ( 9, "0 byte read ;giving up. are we done?" );  // XXX this shoulf not be the end
				done = 1; 	
				break;
			}
			whisper  ( 9, "rxw:%i leg:%i siz:%i-%i\t", rxworker->id, rxbufferleg,  readsize,remainder) ; 
		}
		whisper  ( 9, "\nrxw: %i leg:%i buffer filled to :%i\n", rxworker->id, rxbufferleg,  cursor) ; 
		checkperror ("read buffer"); 	
		//block until the sequencer is ready to push this XXXX  terrible sequencer
		// bufferblock == next expected bufferblock
		// possibly voilates some cocurrency noise
		int sequencer_stalls =0 ; 
		while ( rxbufferleg !=  rxworker->rxconf_parent->next_leg ) {
			usleep ( 1000 ); 
			sequencer_stalls++; 
			assert ( sequencer_stalls  < 100000 && " rx sseqencer stalled");
		}
		whisper ( 5, "rxw:%i dumping leg:%i.%i after %i stalls\n", rxworker->id,  rxbufferleg, rxbuffersize, sequencer_stalls); 
		remainder = rxbuffersize; 
		int writesize=0; 
		cursor = 0 ; 
		while (  remainder ) {
			writesize = write ( STDOUT_FILENO, buffer+cursor, (size_t) MIN( remainder, MAXBSIZE )); 
			cursor += writesize; 
			remainder -= writesize ; 
		}
		checkperror ("write buffer"); 	
		//XXX protect with mutex?
		rxworker->rxconf_parent->next_leg ++ ;
		rxbufferleg = -77;	
		rxbuffersize= -55;
		readlen = readsize = -111;
	}// while !done
	whisper ( 7, "rxw:%i leg:%i done\n", rxworker->id, rxbufferleg); 
	
}

void rxlaunchworkers ( struct rxconf_s * rxconf ) {
	int done =0; 
	int worker_cursor=0; 
	int retcode ;
	rxconf->done_mbox =0; 
	rxconf->next_leg =0;  //initalize sequencer
	assert (tcp_recieve_prep(&(rxconf->sa), &(rxconf->socknum),  rxconf->port ) == 0  && "prep");
	do  {
		rxconf->workers[worker_cursor].id = worker_cursor; 
		rxconf->workers[worker_cursor].rxconf_parent= rxconf; 
		whisper ( 8, "rxworker %i stalled ", worker_cursor); 
		rxconf->workers[worker_cursor].fd = tcp_accept ( &(rxconf->sa), rxconf->socknum); 
		whisper ( 5, "rxw:%i connected fd:%i\n", worker_cursor, rxconf->workers[worker_cursor].fd); 
		// all the bunnies made to hassenfeffer
		retcode = pthread_create ( 
			&rxconf->workers[worker_cursor].thread, 
			NULL, //attrs - none
			(void *(* _Nonnull)(void *))&rxworker,
                        &(rxconf->workers[worker_cursor])
		); 
		checkperror ( "rxpthreadlaunch");  assert ( retcode == 0 && "pthreadlaunch");
		done = rxconf->done_mbox; 
		worker_cursor++; 
	} while (! done ); 
	
}
void rx (struct rxconf_s* rxconf) {
	char buf;
	int readlen; 
	rxlaunchworkers( rxconf); 
}

