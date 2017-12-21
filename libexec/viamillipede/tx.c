#include "worker.h"

u_char * bf; 
// forcefully read utill a bufffer completes or EOF
ssize_t gavage ( int fd, u_char * dest, size_t size ) {
	int remainder=size;
	u_char * dest_cursor = dest; 
	ssize_t accumulator=0; 
	ssize_t readsize; 
	int fuse=1055;  // don't spin  forever
	do	{
		assert ( (fuse > 1 ) && "fuse blown" ); 
		checkperror ( "nuiscance sdinread"); 
		
		readsize = read( fd, dest_cursor ,MIN( MAXBSIZE, remainder) ); 
		checkperror( "gavageread"); 
		whisper( 20, "txingest: read stdin size %ld offset:%i remaining %i \n", readsize,(int) ((u_char*)dest_cursor -  (u_char*)dest), remainder ); 
		if ( readsize < 0 ) { 
			whisper (2, "negative read"); 
			perror ( "negread"); 
			break;
			}
		else {
			remainder -= readsize ; 
			assert ( remainder >= 0); 
			accumulator += readsize;
			assert ( accumulator < kfootsize); 
			dest_cursor += readsize; 
			if ( readsize < 16384) {
				// discourage tinygrams - they just beat us up
				// XXX histgram the readsize and use ema to track optimal effort
				//usleep ( 500); 
			} 
			if ( readsize < 1 )  { // short reads  are the end
				break;
			}
		}
	} while ( (remainder > 0) && ( fuse-- > 0 ) );
	return (  (fuse < 1 )? -1 : accumulator ); 
} 


int ebackoff ( int spins ) {
	int clipped; 
	clipped = MIN( 5000000,  200 + 4*spins  );
	return  ( 1000000 * spins ) ;
}
int dispatch_idle_worker ( struct txconf_s * txconf ) {
	int retcode =-1 ; 
	txstatus ( txconf ); 
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
			//txstatus ( txconf ); 
			spins++; 
			//whisper ( 3, "no workers available backing off\n" ); 
			usleep (1000);
		}
	}

	
return (retcode); 
}

void start_worker ( struct txworker_s * txworker ) {
	txworker->state='d'; 	
	txstatus ( txworker->txconf_parent ); 
}
	
//dump stdin in chunks
void txingest (struct txconf_s * txconf ) {
	int readsize;
	int in_fd = STDIN_FILENO;
	int foot_cursor =0;
	int done =0; 
	u_char taste_buf; 
	unsigned long stream_accumulator =0; 
	int ingest_leg_counter = 0; 
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
			stream_accumulator += readsize ; 
		} else { 
			whisper ( 3, "ingest no more stdin"); 
			done =1;
		}
	}
	whisper ( 3, "ingest complete for fd %i  %lu  bytes\n",in_fd, stream_accumulator); 
	
	
	
}


void txpush ( struct txworker_s *txworker ) {
	//push this buffer out the socket
	int writelen =-1; 
	int writeremainder = txworker->buffersize;
	int cursor=0 ;
	u_char preamble[]= {0xa5,0x5a};
	assert ( writeremainder <= kfootsize ); 
	checkperror( "writesocket nuisnace err"); 
	
	write (txworker->sockfd ,  preamble, 2);  // this XXX hsoule be  a protocol
		whisper (9, "."); 
	write (txworker->sockfd ,  &(txworker->buffersize), sizeof(int)); 
		whisper (9, "."); 
	write (txworker->sockfd ,  &(txworker->bufferleg), sizeof(int)); 
		whisper (9, "."); 

	while (  writeremainder  ) {
		writelen = write ( txworker->sockfd , ((txworker->buffer)+cursor) , MIN (MAXBSIZE,writeremainder)  ) ;
		writeremainder -= writelen; 
		cursor += writelen; 
		whisper (10, "txw:%i push leg:%i.(+%i -%i)  ", txworker->id, txworker->bufferleg, writelen,writeremainder); 
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
	txworker->sockfd = tcp_connect ( txworker->txconf_parent->hostname, txworker->txconf_parent->port); 
	//can the remote end talk? this is lame  but rudimentary q/a session will assert that the tcp stream is able to bear traffic
	retcode = write (txworker->sockfd, hellophrase, 4); 
	checkperror ( "write fail"); 
	retcode = read (txworker->sockfd, &readback, 2); 
	checkperror ("read fail"); 
	assert ( bcmp ( checkphrase, readback, 2 ) == 0 ); 
	whisper ( 8, "txw:%i online and idling fd:%i\n", txworker->id, txworker->sockfd);
	txstatus (txworker->txconf_parent); 
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
			txstatus ( txworker -> txconf_parent ) ; 
			whisper ( 9, "txw:%i is loney after %i spins \n", txworker->id, state_spin); 
		}
		usleep ( 1000 ); 
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
		usleep (201000);  // XXXX
		worker_cursor++;
		}	
	txstatus ( txconf);
}

void txstatus ( struct txconf_s* txconf ) {
	whisper ( 4, "\n");
	for ( int i=0; i < txconf->worker_count ; i++) {
		whisper(4, "%c:%i ", txconf->workers[i].state, txconf->workers[i].bufferleg);
		}
}
void txbusyspin ( struct txconf_s* txconf ) {
	// if there are launche/dispatched /pushing workers; hang here
	int done =0; 
	int busy_cycles; 
	char  instate; 
	while (!done) {
		usleep ( 10000);  // e^n backoff?
		if ( (busy_cycles % 100000) == 0 ) txstatus( txconf ); 
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
	whisper ( 4, "all workers idled after %i spins\n", busy_cycles); 
}
void wat ( ) {
	fprintf (  stderr, "I'm walking here"); 
}
void tx (struct txconf_s * txconf) {
	int retcode; 
	int done = 0; 
	
	//start control channel
        struct sigaction lsigwat;
        sigset_t sigsetmask;
        sigprocmask (SIG_SETMASK, NULL, &sigsetmask);
        lsigwat.sa_flags = 0;
        lsigwat.sa_mask = sigsetmask;
        lsigwat.sa_handler = (void (*)) &wat;
        sigaction (SIGSEGV, &lsigwat,NULL);

	txlaunchworkers ( txconf ); 	
	bf = malloc ( kfootsize); 
	txingest ( txconf ); 
	txbusyspin ( txconf ); 
}
