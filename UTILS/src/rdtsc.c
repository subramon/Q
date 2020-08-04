#include "get_time_usec.h"
#include "rdtsc.h"

//START_FUNC_DECL
uint64_t
RDTSC(
    void
    )
//STOP_FUNC_DECL
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}
