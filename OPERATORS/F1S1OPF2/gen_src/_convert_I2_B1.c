
#include "_convert_I2_B1.h"

int
convert_I2_B1(  
      const int16_t * const restrict in,  
      uint64_t *nn_in,
      uint64_t nR,  
      uint64_t *ptr_num_null,
      uint64_t * out,
      uint64_t *nn_out
      )

{
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( nR == 0 ) { go_BYE(-1); }
  uint64_t num_null = 0;

#pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < nR; i++ ) { 
    int16_t in_val = in[i];
    int out_val;
    int nn_out_val = 1;
    if ( ( in_val != 0 ) && ( in_val != 1 ) ) {
      nn_out_val = 0;
      out_val = 0;
      num_null++;
    }
    else if ( nn_in != NULL ) { 
      int nn_in_val = get_bit_u64(nn_in, i);
      if ( nn_in_val == 0 ) { 
        nn_out_val = 0;
        out_val = 0;
        num_null++;
      }
    }
    else {
      out_val = in_val;
    }
    set_bit_u64(out, i, out_val);
    if ( nn_out != NULL ) { 
      set_bit_u64(nn_out, i, nn_out_val);
    }
  } 
BYE:
  return status;
}
   
