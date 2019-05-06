
#include "vvadd_I4_I4_I4.h"

static void
__operation(
      int32_t a,
      int32_t b, 
      int32_t *ptr_c
      )
      {
      int32_t c;
      c = a + b; 
      *ptr_c = c;
      }

int
vvadd_I4_I4_I4(  
      const int32_t * restrict in1,  
      const int32_t * restrict in2,  
      uint64_t nR,  
      int32_t * restrict out 
      )

{ 
  int status = 0;
// TODO #pragma omp parallel for schedule(static, Q_MIN_CHUNK_SIZE_OPENMP)
// #pragma omp parallel for schedule(static) num_threads(4)
  for ( uint64_t i = 0; i < nR; i++ ) {  
    int32_t inv1 = in1[i]; 
    int32_t inv2 = in2[i]; 
    int32_t outv;
    __operation(inv1, inv2, &outv);
    out[i] = outv;
  } 

  return status;
}

   
