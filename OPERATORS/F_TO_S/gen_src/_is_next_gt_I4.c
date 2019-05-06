
#include "_is_next_gt_I4.h"

int
is_next_gt_I4(  
      const int32_t * restrict in,  
      uint64_t nR,
      is_next_gt_I4_ARGS *ptr_args,
      uint64_t idx // not used for now
      )

{
  int status = 0;
  int32_t prev_val = ptr_args->prev_val;

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
  for ( uint64_t i = 1; i < nR; i++ ) { 
    if ( in[i]  <=  in[i-1] ) { 
      ptr_args->is_violation = 1;
      ptr_args->num_seen += i;
      goto BYE;
    }
  }
  ptr_args->prev_val = in[nR-1];
  ptr_args->num_seen += nR;
BYE:
  return status;
}
   
