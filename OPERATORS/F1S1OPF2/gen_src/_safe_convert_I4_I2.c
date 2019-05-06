
#include "_safe_convert_I4_I2.h"

int
safe_convert_I4_I2(  
      const int32_t * restrict in,
      uint64_t *nn_in,
      uint64_t nR,  
      void *dummy,
      int16_t * out,
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }
  if ( nn_out == NULL ) { go_BYE(-1); }

#pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < nR; i++ ) {
    unsigned int nn_out_i;
    if (  ( in[i] < -32768 ) || ( in[i] > 32767 )  ) {
      out[i] = 0;
      nn_out_i = 0;
    }
    else {
      nn_out_i = 1;
      out[i] = in[i];
    }
    if ( nn_out  ) {
      set_bit_u64(nn_out, i, nn_out_i);
    }
  }
  BYE:
  return status;
}
   
