#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "get_time_usec.h"
#include "hmap_aux.h"

uint64_t
RDTSC(
    void
    )
{
#ifdef ARM
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}

uint32_t
mk_hmap_key(
    void
    )
{
  uint64_t r1 = random() ^ RDTSC();
  uint64_t r2 = random() ^ RDTSC();
  return (uint32_t)( r1 | ( r2 << 32 )  );
}
