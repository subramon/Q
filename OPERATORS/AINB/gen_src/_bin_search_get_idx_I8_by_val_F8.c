
#include "_bin_search_get_idx_I8_by_val_F8.h"

int
bin_search_get_idx_I8_by_val_F8(  
      const double * restrict A,  
      uint64_t nA,
      const double * restrict B,  
      uint32_t nB,
      int64_t *C // [nA] 
      )
{
  int status = 0;

#pragma omp parallel for schedule(static, 256)
  for ( uint64_t i = 0; i < nA; i++ ) { 
    int64_t l_pos;
    if ( status == -1 ) { continue; }
    int l_status = 
      bin_search_F8(B, nB, ((double)(A[i])), NULL, &l_pos);
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
   
