#include "q_incs.h"
#include "sum_struct.h"
#include "sum_B1.h"
#include "_get_bit_u64.h"
int
sum_B1(  
      const uint64_t  * restrict in,  
      uint64_t nR,
      SUM_I_ARGS *ptr_args,
      uint64_t idx
      ) 
{
  int status = 0;
  
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  // Convert number of elements (nR) to number of 64 bit integers (nRprime)
  uint64_t nRprime = nR / 64; 
  uint64_t block_size = nRprime / nT;
  uint64_t gsum = 0;
#pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < nT; t++ ) { 
    uint64_t lsum = 0;
    uint64_t lb = t * block_size;
    uint64_t ub = lb + block_size;
    if ( t == 0      ) { lb = 0;       }
    if ( t == (nT-1) ) { ub = nRprime; }
    for ( uint64_t i  = lb; i < ub; i++ ) {  
      lsum += __builtin_popcountll(in[i]);
    }
#pragma omp critical (_sum_B1)
    {
      gsum += lsum;
    }
  }
  // deal with overflow if any 
  if ( ( nRprime * 64 ) != nR ) { 
    for ( uint64_t i = nRprime * 64; i < nR; i++ ) { 
      gsum += get_bit_u64(in, i);
    }
  }
  ptr_args->val += gsum;
  ptr_args->num += nR;
  return status;
}
