#include "_get_val_F8_by_idx_I1.h"

int
get_val_F8_by_idx_I1(  
      const int8_t * restrict in1,  
      const double * restrict in2,  
      uint64_t nR1,  
      uint64_t nR2,
      double *null_val_as_array,
      double * restrict out 
      )

{ 
  int status = 0;
  if ( in1 == NULL ) { go_BYE(-1); }
  if ( in2 == NULL ) { go_BYE(-1); }
  if ( out == NULL ) { go_BYE(-1); }
  if ( null_val_as_array == NULL ) { go_BYE(-1); }
  double null_val = *null_val_as_array;
#pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < nR1; i++ ) {  
    int8_t inv1 = in1[i]; 
    if ( ( inv1 < 0 ) || ( inv1 >= (int64_t)nR2 ) ) {
      out[i] = null_val;
    }
    else {
      out[i] = in2[inv1];
    }
  } 
BYE:
  return status;
}
   
