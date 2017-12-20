#ifndef utilh
#define utilh
extern int gverbose;
#define whisper( level, ...)  { if ( level < gverbose ) fprintf(stderr,__VA_ARGS__); }
#define checkperror( ... )   do {if (errno != 0) perror ( __VA_ARGS__ );  } while (0); 
#endif

