#include "rand_B1.h"
#include "_rdtsc.h"

//START_FUNC_DECL
int
rand_B1(
  uint64_t *X,
  uint64_t nX,
  RAND_B1_REC_TYPE *ptr_in,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;
  static uint64_t l_sum;

  uint64_t seed = ptr_in->seed;
  double p = ptr_in->probability;
  if ( ( p < 0 ) || ( p > 1 ) ) { go_BYE(-1); }
  if ( idx == 0 ) { //seed has not yet been set
    l_sum = 0;
    if ( ptr_in->seed == 0 ) {
     ptr_in->seed = RDTSC();
    }
    srand48_r(seed, &(ptr_in->buffer));
  }
  //-- Initialize to 0
  uint8_t *lX = (uint8_t *)X;
  uint64_t lnX = nX / 8; 
  if ( ( lnX * 8 ) != nX ) { lnX++; } 
// #pragma omp parallel for
  for ( uint64_t i = 0; i < lnX; i++ ) { 
    lX[i] = 0;
  }
// #pragma omp parallel for
  for ( uint64_t i = 0; i < nX; i++ ) { 
    uint64_t word_idx = i >> 6; /* divide by 64 */
    uint64_t  bit_idx = i & 0x3F; /* remainder after division by 64 */
    double rval = drand48();
    if ( rval <= p ) { 
      uint64_t bval = ( (uint64_t)1 << bit_idx );
      X[word_idx] |= bval;
      l_sum++;
    }
  }
  // fprintf(stderr, "randB1: %d, %llu, %lld, %lf \n", idx, nX, l_sum, p);
BYE:
  return status;
}
