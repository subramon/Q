#include "_split_I4_I2.h"

int
split_I4_I2(  
      const int32_t * restrict in,  
      uint64_t n,  
      int shift,
      int16_t * restrict out1,
      int16_t * restrict out2
      )

{ 
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( out1 == NULL ) { go_BYE(-1); }
  if ( out2 == NULL ) { go_BYE(-1); }
  uint64_t imask = ((uint64_t)1 << shift) - 1;
  int16_t mask = (int16_t) imask;
// TODO PUT BACK #pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < n; i++ ) {  
    int32_t inv1 = in[i]; 
    out1[i] = inv1 >> shift;
    out2[i] = inv1 & mask;
  } 
BYE:
  return status;
}
   
