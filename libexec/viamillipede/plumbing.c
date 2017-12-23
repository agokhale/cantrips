#include "worker.h"

#include "util.h"
#include <sys/socket.h>

// forcefully read utill a bufffer completes or EOF
ssize_t gavage ( int fd, u_char * dest, size_t size ) {
        int remainder=size;
        u_char * dest_cursor = dest;
        ssize_t accumulator=0;
        ssize_t readsize;
        int fuse=1055;  // don't spin  forever
        do      {
                checkperror ( "nuiscance sdinread");
                if ( errno !=0 ) errno = 0 ; //reset nuiscances
                readsize = read( fd, dest_cursor ,MIN( MAXBSIZE, remainder) );
                checkperror( "gavageread");
                whisper( 20, "txingest: read stdin size %ld offset:%i remaining %i \n", readsize,(int) ((u_char*)dest_cursor -
 (u_char*)dest), remainder );
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
        assert ( (fuse > 1 ) && "fuse blown" );
        return (  (fuse < 1 )? -1 : accumulator );
}
void stopwatch_start (struct  timespec * t ) {
        assert ( clock_gettime( CLOCK_UPTIME, t ) == 0);
}
int stopwatch_stop ( struct  timespec * t  , int  whisper_channel) {
        //  stop the timer started at t
        struct timespec stoptime;
        assert ( clock_gettime( CLOCK_UPTIME, &stoptime ) == 0 );
        time_t secondsdiff =     stoptime.tv_sec   - t->tv_sec  ;
        long nanoes =            stoptime.tv_nsec  - t->tv_nsec;

        if ( nanoes < 0 ) {
                // borrow billions place nanoseconds to come up true
                nanoes += 1000000000;
                secondsdiff --;
        }
        u_long ret = MIN( ULONG_MAX,  (secondsdiff * 1000000 ) + (nanoes/1000));
        if ( whisper_channel > 0 ) { whisper ( whisper_channel, "%li.%03li", secondsdiff, nanoes/1000000); }
        return  ret;
}
//return a connected socket fd
int tcp_connect ( char * host, int port )  {
	int ret_sockfd= -1; 
	int retcode;
	struct hostent *lhostent;
	struct addrinfo  laddrinfo;
	struct sockaddr_in lsockaddr;
	//struct sockaddr lsockaddr;
	lhostent = gethostbyname ( host );
	if ( h_errno != 0 ) herror ( "gethostenterror" ); 
	assert ( h_errno == 0  && "hostname fishy"); 
	lsockaddr.sin_family = AF_INET; 
	lsockaddr.sin_port = htons( port );
	memcpy(&(lsockaddr.sin_addr), lhostent->h_addr_list [0], sizeof(struct in_addr)); //y u hate c?
	ret_sockfd =  socket ( AF_INET,SOCK_STREAM, 0 );  
	assert ( ret_sockfd > 0  && "socket fishy"); 
	retcode = connect ( ret_sockfd, (struct sockaddr*) &(lsockaddr), sizeof (struct sockaddr) ); 
	checkperror ( "socket connect"); 
	if ( retcode != 0 ) perror ("connect() errrr:"); 
	assert ( retcode == 0 && "connect fail "); 
	int sockerr; 
	u_int sockerrsize = sizeof(sockerr); //uhg
	getsockopt ( ret_sockfd ,  SOL_SOCKET, SO_ERROR, &sockerr, &sockerrsize); 
	checkperror ( "connect"); 
	assert ( sockerr ==  0); 
	whisper (8,  "        connected to %s:%i\n", host, port); 
	return ( ret_sockfd ); 
}
int  tcp_recieve_prep (struct sockaddr_in * sa, int * socknum,  int inport) {
        int one=1;
        int retcode;
        int lsock = -1;
        *socknum = socket (AF_INET, SOCK_STREAM, 0);
        sa->sin_family= AF_INET;
        sa->sin_addr.s_addr=  htons (INADDR_ANY);
        sa->sin_port = htons (inport);
        whisper (7, "bind sockid: %i\n",*socknum);
        setsockopt(*socknum,SOL_SOCKET,SO_REUSEPORT,(char *)&one,sizeof(one));
        retcode = bind (*socknum, (struct sockaddr *) sa,sizeof (struct sockaddr_in) );
        if ( retcode != 0 ) { perror ("bind failed"); assert (0); }
	checkperror("bindfail"); 
        whisper (9, "      listen sockid: %i\n",*socknum);
        retcode = listen ( *socknum, 6) ;
        if ( retcode != 0) { perror ("listen fail:\n"); assert ( 0 );};
	return retcode ; 
}

int tcp_accept(struct sockaddr_in *  sa , int socknum ){  
        int out_sockfd;
        socklen_t socklen = sizeof (struct  sockaddr_in ) ;
        whisper (7, "accept sockid: %i\n",socknum);
        out_sockfd = accept (socknum,(struct sockaddr *)sa,&socklen);
        whisper (7, "socket %i accepted to fd:%i \n" , socknum,out_sockfd);
	checkperror  ("acceptor"); 
        return (out_sockfd);
}

