
#include "_max_I1.h"

int
max_I1(  
      const int8_t * restrict in,
      uint64_t nR,  
      void *in_ptr_args,
      uint64_t idx
      )

{
  int status = 0;
  int8_t inv; 
  REDUCE_max_I1_ARGS *ptr_args;
  ptr_args = (REDUCE_max_I1_ARGS *)in_ptr_args;

  if ( idx == 0 ) {
    ptr_args->max_val = INT8_MIN;
    ptr_args->num     = 0;
    ptr_args->max_index = -1;
  }
  
  int8_t curr_val = ptr_args->max_val;
  int64_t curr_index = ptr_args->max_index;
  uint32_t num_threads = sysconf(_SC_NPROCESSORS_ONLN);

  int8_t max_val = INT8_MIN;
  uint64_t block_size = nR / num_threads;
#pragma omp parallel for schedule(static)
  for ( uint32_t t = 0; t < num_threads; t++ ) { 
    uint64_t lb = t * block_size;
    uint64_t ub = lb + block_size;
    if ( t == (num_threads-1) ) { ub = nR; }
    int8_t lval = INT8_MIN;
    int8_t val = INT8_MIN;
    int64_t index = -1;
    for ( uint64_t i  = lb; i < ub; i++ ) {  
      inv = in[i];
      val = mcr_max(lval, inv);
      if (val != lval){
        lval = val;
        index = i + idx;
      }
    }
#pragma omp critical (_max_I1)
    {
    max_val = mcr_max(curr_val, lval);
    if ((max_val != curr_val) || ((max_val == curr_val) && (index < curr_index))){
       curr_val = max_val;
       curr_index = index;
    }
    }
  }
  ptr_args->max_val = curr_val;
  ptr_args->max_index = curr_index;
  ptr_args->num     += nR;
  return status;
}
   
