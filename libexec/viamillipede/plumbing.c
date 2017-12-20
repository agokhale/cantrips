#include "worker.h"

#include "util.h"
#include <sys/socket.h>

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

