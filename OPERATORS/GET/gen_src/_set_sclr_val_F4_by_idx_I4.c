#include "_set_sclr_val_F4_by_idx_I4.h"

int
set_sclr_val_F4_by_idx_I4(  
      const int32_t * restrict in,   /* [nR1] */
      uint64_t nR1,  
      float * out,   /* [nR2] */
      uint64_t nR2,
      float *ptr_out_sclr // TODO P3 No need for de-reference
      )

{ 
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  float out_sclr = *ptr_out_sclr;

// TODO #pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < nR1; i++ ) {  
    int32_t inv1 = in[i]; 
    if ( ( inv1 < 0 ) || ( inv1 >= (int64_t)nR2 ) ) {
      continue; 
    }
    out[inv1] = out_sclr;
  } 
BYE:
  return status;
}
   
