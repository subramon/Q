#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>
#include "q_macros.h"
#include "tmpl_rand.h"

static inline uint64_t RDTSC()
{
  unsigned int hi, lo;
    __asm__ volatile("rdtsc" : "=a" (lo), "=d" (hi));
      return ((uint64_t)hi << 32) | lo;
}

int
random_F8(
  double *X,
  uint64_t nX,
  RANDOM_F8_REC_TYPE *ptr_in,
  bool is_first
  )
//STOP_FUNC_DECL
{
  int status = 0;

  uint64_t seed = ptr_in->seed;
  double lb = ptr_in->lb;
  double ub = ptr_in->ub;
  if ( is_first ) { //seed has not yet been set
    if ( seed == 0 ) {
     seed = RDTSC();
    }
    srand48(seed);
  }
  double range = ub - lb;
  for ( uint64_t i = 0; i < nX; i++ ) { 
    double x = drand48();
    X[i] = (double) (lb + (range * x) );
#ifdef DEBUG
    if ( ( X[i] < lb ) || ( X[i] > ub ) ) { 
      go_BYE(-1);
    }
#endif
  }
BYE:
  return status;
}
