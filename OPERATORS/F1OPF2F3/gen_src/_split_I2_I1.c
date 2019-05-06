#include "_split_I2_I1.h"

int
split_I2_I1(  
      const int16_t * restrict in,  
      uint64_t n,  
      int shift,
      int8_t * restrict out1,
      int8_t * restrict out2
      )

{ 
  int status = 0;
  if ( in == NULL ) { go_BYE(-1); }
  if ( out1 == NULL ) { go_BYE(-1); }
  if ( out2 == NULL ) { go_BYE(-1); }
  uint64_t imask = ((uint64_t)1 << shift) - 1;
  int8_t mask = (int8_t) imask;
// TODO PUT BACK #pragma omp parallel for schedule(static)
  for ( uint64_t i = 0; i < n; i++ ) {  
    int16_t inv1 = in[i]; 
    out1[i] = inv1 >> shift;
    out2[i] = inv1 & mask;
  } 
BYE:
  return status;
}
   
