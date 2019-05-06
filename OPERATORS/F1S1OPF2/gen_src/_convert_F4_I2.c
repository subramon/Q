
#include "_convert_F4_I2.h"

int
convert_F4_I2(  
      const float * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int16_t * restrict out,  
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
   
