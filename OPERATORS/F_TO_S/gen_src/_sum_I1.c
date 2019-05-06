
#include "_sum_I1.h"

int
sum_I1(  
      const int8_t * restrict in,
      uint64_t nR,  
      void *in_ptr_args,
      uint64_t idx
      )

{
  int status = 0;
  REDUCE_sum_I1_ARGS *ptr_args = (REDUCE_sum_I1_ARGS *)in_ptr_args;

  if ( idx == 0 ) {
    ptr_args->sum_val = 0;
    ptr_args->num     = 0;
  }
  
  int64_t curr_val = 0;
  uint32_t num_threads = sysconf(_SC_NPROCESSORS_ONLN);

  uint64_t block_size = mcr_max(1, nR / num_threads);
#pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < num_threads; t++ ) { 
    uint64_t lb = t * block_size;
    uint64_t ub = lb + block_size;
    if ( t == (num_threads-1) ) { ub = nR; }
    int64_t lval = 0;
#pragma omp simd reduction(+:lval)
    for ( uint64_t i  = lb; i < ub; i++ ) {  
      lval += mcr_nop(in[i]);
    }
#pragma omp critical (_sum_I1)
    {
    curr_val = mcr_sum(curr_val, lval);
    }
  } 
  ptr_args->sum_val += curr_val;
  ptr_args->num     += nR;
  return status;
}
   
