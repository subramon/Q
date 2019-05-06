
#include "_bin_search_ainb_F4_I4.h"

int
bin_search_ainb_F4_I4(  
      const float * restrict A,  
      uint64_t nA,
      const int32_t * restrict B,  
      uint32_t nB,
      uint64_t *C // nA bytes
      )
{
  int status = 0;

  memset(C, 0, nA); // Note that C must have nA bytes
#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) { 
    int64_t pos;
    int l_status = 0;
    int x_status = bin_search_I4(B, nB, ((int32_t)(A[i])), NULL, &pos);
    if ( x_status < 0 ) {  
      if ( l_status == 0 ) { 
        l_status = -1;
        status = -1;
      }
    }
    if ( pos >= 0 ) {
      set_bit_u64(C, i, 1);
    }
  }

  return status;
}
   
