#include "q_incs.h"
#include "get_time_usec.h"
#include "rdtsc.h"

uint64_t
RDTSC(
    void
    )
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}

/* 
int main(int argc, char* argv[]) {
  uint64_t tick = RDTSC();  // tick before
  int i ;
  for (i = 1; i < argc; ++ i) {
    system(argv[i]); // start the command
  }
  // printf("%ld",RDTSC() - tick); // difference
  return 0;
}
*/
