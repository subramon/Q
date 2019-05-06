
#include "_par_is_next_gt_F8.h"

int
par_is_next_gt_F8(  
      const double * restrict in,  
      uint64_t nR,
      par_is_next_gt_F8_ARGS *ptr_args,
      uint64_t idx // not used for now
      )

{
  int status = 0;
  uint32_t nT = sysconf(_SC_NPROCESSORS_ONLN);
  uint64_t t_num_violation[nT];
  double prev_val = ptr_args->prev_val;

  if ( ptr_args->is_violation != 0 ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }
  if ( in == NULL ) { go_BYE(-1); }
  if ( ptr_args->num_seen == 0 ) { 
    // no comparison to make 
  }
  else {
    if ( in[0]  <=  prev_val ) { 
      ptr_args->is_violation = 1;
      ptr_args->num_seen++;
      return status;
    }
  }
  for ( uint32_t tid = 0; tid < nT; tid++ ) { t_num_violation[tid] = 0; }
  uint64_t block_size = mcr_max(1, nR / nT);

#pragma omp parallel for schedule(static)
  for ( uint32_t tid = 0; tid < nT; tid++ ) { 
    uint64_t lb = tid * block_size;
    uint64_t ub = lb + block_size;
    if ( lb == 0 ) { lb = 1; }
    if ( tid == (nT-1) ) { ub = nR; }
    uint64_t num_violation = 0;
#pragma omp simd reduction(+:num_violation)
    for ( uint64_t i  = lb; i < ub; i++ ) {  
      num_violation += in[i]  <=  in[i-1];
    }
    t_num_violation[tid] = num_violation;
  }
  for ( uint32_t tid = 0; tid < nT; tid++ ) { 
    if ( t_num_violation[tid] > 0 ) { 
      ptr_args->is_violation = 1;
      return status;
    }
  }
  ptr_args->num_seen += nR;
  ptr_args->prev_val = in[nR-1];
BYE:
  return status;
}
