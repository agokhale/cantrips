#ifndef cfgh
#define cfgh

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <stdlib.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/param.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>
#include <pthread.h> 

#include "util.h"

#define kfootsize (1024 * 1024 )
#define kfootcount 4 

struct txconf_s;  // forward decl to permit inception 
struct rxconf_s;  // forward decl to permit inception 
struct txworker_s {
	int id; 
	struct txconf_s *txconf_parent;
	char state;
	pthread_mutex_t mutex;
	pthread_t thread; 
	int sockfd ;
	u_char * buffer; 
	int buffersize; // is ths leg filled
	int bufferleg;  // leg is the total ordering sequence  for the stream 
	
};

struct txconf_s {
	int worker_count;
	struct txworker_s workers[16];	//XXX make dynamic??? 
	char * hostname; 
	unsigned short port;
	int sockfd;
	
} ;


// the bearer channel 
struct millipacket { 
	unsigned long packetref; // pr = ( streamstart  % window_size)
	unsigned long size;
	void * payload; 
};

struct rxworker_s {
	int id;
	int fd;
	int socknum; 
	struct rxconf_s *rxconf_parent;
	pthread_mutex_t mutex; 
	pthread_t thread;
};
struct rxconf_s {
	int workercount; 
	struct sockaddr_in sa;  // reusable bound sa for later accepts
	int socknum ;  // reusable bound socket number  later accepts
	unsigned short port; 
	struct rxworker_s workers[16]; 
	int next_leg ; 
	int done_mbox; 
} ;

	
#endif
