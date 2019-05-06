
#include "_convert_I2_I4.h"

int
convert_I2_I4(  
      const int16_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int32_t * restrict out,  
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }

#pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < nR; i++ ) { 
    out[i] = in[i];
  } 
BYE:
  if ( status < 0 ) { WHEREAMI; }
  return status;
}
   
