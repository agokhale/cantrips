#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h> //maxbsize
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

void stopwatch_start(struct timespec *t) {
  assert(clock_gettime(CLOCK_UPTIME, t) == 0);
}
int stopwatch_stop(struct timespec *t) {
  //  stop the timer started at t
  // returns usec resolution diff of time
  struct timespec stoptime;
  assert(clock_gettime(CLOCK_UPTIME, &stoptime) == 0);
  time_t secondsdiff = stoptime.tv_sec - t->tv_sec;
  long nanoes = stoptime.tv_nsec - t->tv_nsec;
  if (nanoes < 0) {
    // borrow billions place nanoseconds to come up true
    nanoes += 1000000000;
    secondsdiff--;
  }
  u_long ret =
      MIN(ULONG_MAX, (secondsdiff * 1000000) + (nanoes / 1000)); // in usec
  return ret;
}

void usage () {
printf ( "futileread  file  count threshhold_us: print slower io ");
exit (1); 
}
int main(int argc, char **argv) {
  if ( argc != 4) usage(); 
  assert(argv[1]);
  int fd = open(argv[1], O_RDONLY);
  char buf[MAXBSIZE];
  struct timespec tmm;
  unsigned int howlong;
  unsigned int thresh_us; 
  int readlen = 0;
  int cursor = 0;
  assert(fd > 2);
  thresh_us = atoi (argv[3]);
  assert (thresh_us> 0);
  do {
    stopwatch_start(&tmm);
    readlen = read(fd, buf, 1024);
    howlong = stopwatch_stop(&tmm);
    if (howlong > thresh_us) {
      printf("%d,%d\n", cursor, howlong);
    }
    cursor++;
  } while (readlen > 0 && cursor < atoi(argv[2]));
  close(fd);
}
