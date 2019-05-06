
#include "_shift_right_I4.h"

int
shift_right_I4(  
      const int32_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      int *ptr_shift_by,
      int32_t * out,
      uint64_t *nn_out
      )

{
  int status = 0;
  int shift_by = *ptr_shift_by;

  if ( ( shift_by < 0 ) || ( shift_by > 64 ) ) { go_BYE(-1); }
  if ( in == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

#pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < nR; i++ ) { 
    out[i] =  (( uint32_t ) in[i]) << shift_by;
  } 
BYE:
  return status;
}
   
