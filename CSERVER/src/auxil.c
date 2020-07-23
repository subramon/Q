#include <stdint.h>
#include <sys/time.h>
#include "auxil.h"

// START FUNC DECL
uint64_t get_time_usec(
    void
    )
// STOP FUNC DECL
{
  struct timeval Tps;
  struct timezone Tpf;
  unsigned long long t = 0, t_sec = 0, t_usec = 0;

  gettimeofday (&Tps, &Tpf);
  t_sec  = (uint64_t )Tps.tv_sec;
  t_usec = (uint64_t )Tps.tv_usec;
  t = t_sec * 1000000 + t_usec;
  return t;
}
/* assembly code to read the TSC */
uint64_t 
RDTSC(
    void
    )
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int hi, lo;
  __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}
