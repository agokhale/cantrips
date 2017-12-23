#include "worker.h"

int dispatch_idle_worker ( struct txconf_s * txconf ) {
	int retcode =-1 ; 
	txstatus ( txconf , 6); 
	int spins; 
	while (   retcode < 0  ) {
		//XXX fix bounds 
		for ( int i = 0 ; (i < txconf->worker_count) && (retcode < 0 ) ; i++ ) {
			//pthread_mutex_lock (&(txconf->workers[i].mutex));
			if ( txconf->workers[i].state == 'i' ) {
				//hold lock untill the buffer is filled
				retcode = i; 
				spins = 0 ;	
			} else {
				//pthread_mutex_unlock (&(txconf->workers[i].mutex));
			}
		}
		if (retcode <  0 ) {
			txstatus ( txconf , 19); 
			spins++; 
			//whisper ( 3, "no workers available backing off\n" ); 
			usleep (1000);
		}
	}

	
return (retcode); 
}

void start_worker ( struct txworker_s * txworker ) {
	txworker->state='d'; 	
	txstatus ( txworker->txconf_parent, 6 ); 
}
	
//dump stdin in chunks
void txingest (struct txconf_s * txconf ) {
	int readsize;
	int in_fd = STDIN_FILENO;
	int foot_cursor =0;
	int done =0; 
	u_char taste_buf; 
	int ingest_leg_counter = 0; 
	txconf->stream_total_bytes=0; 
	checkperror("nuisancse ingest err");
	while ( !done ) {
		// select XXX a free foot worker
		//here lies a conundrum - if the input is slow, we will not fill buffers, 
		// how long should we wait before attempttig to grab what we want?
		// waiting n ms for a kfootsize should be an accepable tradeoff or self tuning
		// perhaps wait longer for less overhead  or  wait %1 of iotime? or wait vs achievable BW?
		usleep ( 1 * 1000); 
		checkperror ( "stdinread");
		readsize = read ( in_fd  , &taste_buf , 1 ); // taste the input  for existance
		// i have amanaged to turn a  cs undergrad problem poorly
		if ( readsize > 0 ) { 
			//fixup the buffer because we ate a byte for tasting ; conversely all our read maths are b0rked fencepostly
			// as so as we dispatch - another thread writes  a frame- potentially empty
			// XXX find the idle worker , lock it and dispatch as seprarte calls -- perhaps
			int worker = dispatch_idle_worker ( txconf ); 
			txconf->workers[worker].buffer[0] = taste_buf;
			readsize = gavage (  in_fd ,(u_char *) (txconf->workers[worker].buffer)+1 , kfootsize-1  ) ;  // unfortunate alignment due to taste
			whisper ( 7, "\ntxw:%i read leg %i : fd:%i siz:%i\n",worker,  ingest_leg_counter, in_fd, kfootsize-1); 
			if ( readsize > kfootsize-1) { whisper (1,"too big read %i", readsize); }
			assert ( readsize+1 <= kfootsize ); 
			txconf->workers[worker].buffersize = readsize+1;   // +1 for the tasing byte
			txconf->workers[worker].bufferleg = ingest_leg_counter; 
			start_worker ( &(txconf->workers[worker]) );
			ingest_leg_counter ++; 
			txconf->stream_total_bytes += readsize ; 
		} else { 
			whisper ( 13, "ingest no more stdin"); 
			done =1;
		}
	}

	whisper ( 4, "ingest complete for %lu(bytes) in ",txconf->stream_total_bytes); 
	u_long usecbusy = stopwatch_stop( &(txconf->ticker),4 );
	//bytes per usec - thats interesting 
	whisper (4, " %8.4f mbps\n" , ( txconf->stream_total_bytes *0.0000001) / (0.000001 * usecbusy  )    );
}


void txpush ( struct txworker_s *txworker ) {
	//push this buffer out the socket
	int writelen =-1; 
	txworker->writeremainder = txworker->buffersize;
	int cursor=0 ;
	u_char preamble[]= {0xa5,0x5a};
	assert ( txworker->writeremainder <= kfootsize ); 
	checkperror( "writesocket nuisnace err"); 
	
	write (txworker->sockfd ,  preamble, 2);  // this XXX hsoule be  a protocol
		whisper (9, "."); 
	write (txworker->sockfd ,  &(txworker->buffersize), sizeof(int)); 
		whisper (9, "."); 
	write (txworker->sockfd ,  &(txworker->bufferleg), sizeof(int)); 
		whisper (9, "."); 

	while (  txworker->writeremainder  ) {
		writelen = write(txworker->sockfd , ((txworker->buffer)+cursor) , MIN (MAXBSIZE,txworker->writeremainder) ) ;
		txworker->writeremainder -= writelen; 
		cursor += writelen; 
		whisper (10, "txw:%i push leg:%i.(+%i -%i)  ",txworker->id,txworker->bufferleg,writelen,txworker->writeremainder); 
	}
	checkperror( "writesocket"); 
	assert ( writelen );
	assert( errno == 0 ); 
	txworker->state='i'; 
	txworker->buffersize=0; 
	whisper ( 6 , "txw:%i  leg:%i unlocked \n" , txworker->id, txworker->bufferleg); 
	txworker->bufferleg=-99; 
	//pthread_mutex_unlock( &(txworker->mutex)); 
}
void txworker (struct  txworker_s *txworker ) {
	int done =0; 
	int retcode =-1; 
	char hellophrase[]="yoes";
	char checkphrase[]="ok";
	int state_spin =0; 
	char readback[2048]; 
	pthread_mutex_init ( &(txworker->mutex)	, NULL ) ; 
	pthread_mutex_lock ( &(txworker->mutex));
	txworker->state = 'c'; //connecting
	int target_count = txworker->txconf_parent->target_port_count;
	assert ( target_count > 0 ); 
	txworker->sockfd = tcp_connect ( 
		txworker->txconf_parent->target_ports[txworker->id % target_count].name, 
		txworker->txconf_parent->target_ports[txworker->id % target_count].port); 
	//can the remote end talk? this is lame  but rudimentary q/a session will assert that the tcp stream is able to bear traffic
	retcode = write (txworker->sockfd, hellophrase, 4); 
	checkperror ( "write fail"); 
	retcode = read (txworker->sockfd, &readback, 2); 
	checkperror ("read fail"); 
	assert ( bcmp ( checkphrase, readback, 2 ) == 0 ); 
	whisper ( 8, "txw:%i online and idling fd:%i\n", txworker->id, txworker->sockfd);
	txstatus (txworker->txconf_parent,7); 
	txworker->state = 'i'; //idle
	txworker->buffer = calloc ( 1,(size_t) kfootsize ); 
	txworker->buffersize = 0 ; 
	checkperror( "worker buffer allocator");
	pthread_mutex_unlock ( &(txworker->mutex));
	while ( !done ) {
		pthread_mutex_lock ( &(txworker->mutex));
		switch (txworker->state) {
			case 'i': break; //idle
			case 'd': txpush ( txworker );  break; 
			default: assert( -1 && "bad zoot");
			}
		pthread_mutex_unlock ( &(txworker->mutex));
		state_spin ++; 
		if ( (state_spin % 1000) == 0 && ( txworker->state == 'i' ) )  {
			txstatus ( txworker -> txconf_parent,10 ) ; 
			whisper ( 9, "txw:%i is loney after %i spins \n", txworker->id, state_spin); 
		}
		usleep ( 100 ); 
	} // while !done 
} //  txworker

void txlaunchworkers ( struct txconf_s * txconf) {
	int worker_cursor = 0;
	int ret;	

	for ( int i=0; i < 16 ; i++) {
		txconf->workers[i].state = '0'; // unitialized
		txconf->workers[i].txconf_parent = txconf; // allow inpection/inception
		txconf->workers[i].bufferleg = -66; // 
		txconf->workers[i].buffersize = -66; // 
		txconf->workers[i].sockfd = -66; // 
	}

	while ( worker_cursor < txconf->worker_count )  {
		whisper ( 8, "launching %i\n", worker_cursor); 
		txconf->workers[worker_cursor].state = 'L';
		txconf->workers[worker_cursor].id = worker_cursor; 
		//digression: pthreads murders all possible kittens stored in  argument types
		ret = pthread_create ( 
			&(txconf->workers[worker_cursor].thread ),
			NULL ,
			//clang suggest this gibberish, why question?
			(void *(* _Nonnull)(void *))&txworker,  
			&(txconf->workers[worker_cursor]) 
			);
		checkperror ("pthread launch"); 
		assert ( ret == 0 && "pthread launch"); 
		//allow the remote connection some refractory time to spawn another accept
		usleep (10000);  
		worker_cursor++;
		}	
	txstatus ( txconf, 5);
}

void txstatus ( struct txconf_s* txconf , int log_level) {
	whisper ( log_level, "\n");
	
	for ( int i=0; i < txconf->worker_count ; i++) {
		
		whisper(log_level, "%c:%i-%i ", 
				txconf->workers[i].state, 
				txconf->workers[i].bufferleg,
				(txconf->workers[i].writeremainder) >> 10 //kbytes are sufficient
			);
		}
}
void txbusyspin ( struct txconf_s* txconf ) {
	// if there are launche/dispatched /pushing workers; hang here
	int done =0; 
	int busy_cycles; 
	char  instate; 
	while (!done) {
		usleep ( 1000);  // e^n backoff?
		if ( (busy_cycles % 100) == 0 ) txstatus( txconf, 4 ); 
		busy_cycles++; 
		int busy_workers = 0; 
		for ( int i =0; i < txconf->worker_count ; i++ ) {
			//pthread_mutex_lock (  &(txconf->workers[i].mutex) ); 
			instate =  txconf->workers[i].state	;
			//pthread_mutex_unlock (  &(txconf->workers[i].mutex) ); 
			if ( instate != 'i') busy_workers++;  // XXX janky structure  continue
		} 
		done = ( busy_workers == 0 ) ; 
	}
	whisper ( 4, "\nall workers idled after %i spins\n", busy_cycles); 
}
struct txconf_s *gtxconf; 
void wat ( ) {
	struct txconf_s *txconf=gtxconf;
	whisper ( 1, "\n%lu(bytes) in ",txconf->stream_total_bytes); 
	u_long usecbusy = stopwatch_stop( &(txconf->ticker),2 );
	whisper ( 1 , "\n" ); 
	txstatus  ( txconf, 1 );  
	//bytes per usec - thats interesting  bytes to mb 
	whisper (1, "\n %8.4f mbps\n" , ( txconf->stream_total_bytes / ( 1.0 *  usecbusy  ))    );
}


void tx (struct txconf_s * txconf) {
	int retcode; 
	int done = 0; 
	gtxconf = txconf;	
	//start control channel
        signal (SIGINFO, &wat);
	stopwatch_start( &(txconf->ticker) ); 
	txlaunchworkers( txconf ); 	
	txingest ( txconf ); 
	txbusyspin ( txconf ); 

	whisper ( 2, "all complete for %lu(bytes) in ",txconf->stream_total_bytes); 
	u_long usecbusy = stopwatch_stop( &(txconf->ticker),2 );
	//bytes per usec - thats interesting   ~== to mbps
	whisper (1, " %8.4f mbps\n" , ( txconf->stream_total_bytes  / ( 1.0 * usecbusy  ))    );
}
