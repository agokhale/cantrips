#include "worker.h"

void rxworker ( struct rxworker_s * rxworker ) {
	int done =0; 
	int readsize;
	int readlen;  // XXX 
	char * buffer;
	char  okphrase[] ="ok";
	char  checkphrase[] ="yoes";
	buffer = calloc ( 1 , (size_t)kfootsize );
	whisper ( 8, "   rx worker  connected id%i fd:%i\n", rxworker->id, rxworker->sockfd); 
	read ( rxworker->sockfd , buffer, (size_t)  4 ); //XXX this is vulnerable to slow starts
	if ( bcmp ( buffer, checkphrase, 4 ) == 0 ) 
		{ whisper ( 8, "checkphrase ok\n"); } 
	else 
		{ assert (-1 && "checkphrase failure "); }	

	checkperror ("checkphrase  nuiscance ");
	assert ( write (rxworker->sockfd, okphrase, (size_t)  2 ) && "okwritefail");
	checkperror ( "signaturewrite "); 
	// /usr/src/contrib/netcat has a nice pipe input routine XXX perhaps lift it
	while ( ! done) {
		struct millipacket_s pkt; 
		readlen = read ( rxworker->sockfd , &pkt, sizeof(struct millipacket_s)); 
		whisper ( 19 ,"rxw:%i preamble: len %i\n", rxworker->id, readlen); 
		// this is where we expect to die when eof comes for us; or the line idles
		//assert ( readlen == 2 && "preamble read failure"); 
		// so dont' assert 
		if ( readlen < 0 ) {
			assert (readlen  && " badpackethreader read, are we done now?");
		}
		if ( readlen == 0 ) { 	
			whisper ( 6, "rxw:%i  exits after empty preamble", rxworker->id); 
			pthread_exit( rxworker );  // no really we are done, and who wants our exit status?
			continue;
		}; 
		assert ( readlen == sizeof(struct millipacket_s)); 
		assert ( pkt.preamble == preamble_cannon_ul   && "preamble check");
		assert ( pkt.size >= 0 ); 
		assert ( pkt.size <= kfootsize); 
		assert ( pkt.size >  0);  
		assert ( readlen = sizeof(int)); 
		whisper ( 9, "wrk:%i leg:%lu siz:%lu caught new leg  \n", rxworker->id,  pkt.leg_id , pkt.size); 
		int remainder = pkt.size; 
		assert ( remainder <= kfootsize); 
		int cursor = 0;

		while (  remainder && !done  ) {
			readsize = read ( rxworker->sockfd, buffer+cursor, MIN(remainder, MAXBSIZE )); 
			cursor += readsize; 
			remainder -= readsize ; 
			assert ( readsize > 0 );  //XXX 
			if (readsize == 0) { //XXXXXXXX 
				whisper ( 9, "0 byte read ;giving up. are we done?" );  // XXX this should not be the end
				done = 1; 	
				break;
			}
			whisper  ( 9, "rxw:%i leg:%lu siz:%i-%i\t", rxworker->id, pkt.leg_id ,  readsize,remainder) ; 
		}
		whisper  ( 9, "\nrxw: %i leg:%lu buffer filled to :%i\n", rxworker->id, pkt.leg_id,  cursor) ; 
		checkperror ("read buffer"); 	
		// XXX crc32 check
		//block until the sequencer is ready to push this 
		///XXXX  terrible sequencer
		// bufferblock == next expected bufferblock
		// possibly voilates some cocurrency noise
		int sequencer_stalls =0 ; 
		while ( pkt.leg_id !=  rxworker->rxconf_parent->next_leg ) {
			usleep ( 1000 ); 
			sequencer_stalls++; 
			assert ( sequencer_stalls  < 100000 && " rx sseqencer stalled");
		}
		whisper ( 5, "rxw:%i dumping leg:%lu.%lu after %i stalls\n", rxworker->id,  pkt.leg_id, pkt.size, sequencer_stalls); 
		remainder = pkt.size; 
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
		readlen = readsize = -111;
	}// while !done
	whisper ( 7, "rxw:%i  done\n", rxworker->id); 
	
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
		rxconf->workers[worker_cursor].sockfd = tcp_accept ( &(rxconf->sa), rxconf->socknum); 
		whisper ( 5, "rxw:%i connected fd:%i\n", worker_cursor, rxconf->workers[worker_cursor].sockfd); 
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

