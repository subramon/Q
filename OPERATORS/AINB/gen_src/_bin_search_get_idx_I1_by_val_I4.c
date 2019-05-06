
#include "_bin_search_get_idx_I1_by_val_I4.h"

int
bin_search_get_idx_I1_by_val_I4(  
      const int32_t * restrict A,  
      uint64_t nA,
      const int32_t * restrict B,  
      uint32_t nB,
      int8_t *C // [nA] 
      )
{
  int status = 0;

#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) { 
    int64_t l_pos;
    if ( status == -1 ) { continue; }
    int l_status = 
      bin_search_I4(B, nB, ((int32_t)(A[i])), NULL, &l_pos);
    if ( ( l_status < 0 ) && ( status == 0 ) ) { status = -1; continue; }
    if ( l_pos >= 0 )  {
      if ( (uint64_t)l_pos >= nB ) {  
        /* should never happen. Being Extra cautious */
        C[i] = -1; status = -1; continue; 
      }
      else {
        C[i] = l_pos;
      }
    }
    else {
      C[i] = -1;
    }
  }
  if ( status < 0 ) { go_BYE(-1); }
BYE:
  return status;
}
   
