#include "q_incs.h"
#include "sum_B1.h"
#include "_get_bit_u64.h"

//START_FUNC_DECL
int
sum_B1(  
      const uint64_t  * restrict in,  
      uint64_t nR,
      REDUCE_sum_B1_ARGS *ptr_args,
      uint64_t idx
      ) 
//STOP_FUNC_DECL
{
  int status = 0;

  if ( idx == 0 ) {
    ptr_args->sum_val = 0;
    ptr_args->num     = 0;
  }
  
  // TODO uint32_t num_threads = sysconf(_SC_NPROCESSORS_ONLN);
  uint32_t num_threads = 1;
  // Convert number of elements (nR) to number of 64 bit integers (nRprime)
  uint64_t nRprime = nR / 64; 
  uint64_t block_size = nRprime / num_threads;
  if ( block_size == 0 ) { block_size = 1; }

  uint64_t g_sum = 0;
// #pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < num_threads; t++ ) { 
    uint64_t l_sum = 0;
    uint64_t lb = t * block_size;
    uint64_t ub = lb + block_size;
    if ( t == (num_threads-1) ) { ub = nRprime; }
    if ( lb >= nRprime ) { continue; }
    for ( uint64_t i  = lb; i < ub; i++ ) {  
      l_sum += __builtin_popcountll(in[i]);
    }
// #pragma omp critical (_sum_B1)
    {
    g_sum += l_sum;
    }
  } 
  // deal with overflow if any 
  if ( ( nRprime * 64 ) != nR ) { 
    for ( uint64_t i = nRprime * 64; i < nR; i++ ) { 
      g_sum += get_bit_u64(in, i);
    }
  }
  ptr_args->sum_val += g_sum;
  ptr_args->num     += nR;
  /* fprintf(stderr, "sumB1: %d, %d: %d ===> %d: %d \n", 
      idx, g_sum, nR, ptr_args->sum_val, ptr_args->num);
      */
  return status;
}
