#include "_add_val_I2_by_idx_I2.h"

int
add_val_I2_by_idx_I2(  
      const int16_t * restrict idx,   /* [nR_src] */
      uint64_t nR_src,
      const int16_t * restrict src,   /* [nR_src] */
      int16_t * dst,   /* [nR_dst] */
      uint64_t nR_dst
      )

{ 
  int status = 0;
  if ( idx == NULL ) { go_BYE(-1); }
  if ( src == NULL ) { go_BYE(-1); }
  if ( dst == NULL ) { go_BYE(-1); }
  if ( nR_src == 0 ) { go_BYE(-1); }
  if ( nR_dst == 0 ) { go_BYE(-1); }

#pragma omp parallel for schedule(static, 1024)
  for ( uint64_t i = 0; i < nR_src; i++ ) {  
    int16_t lidx = idx[i]; 
    if ( ( lidx < 0 ) || ( lidx >= (int64_t)nR_dst ) ) {
      continue; 
    }
    dst[lidx] += src[i];
  } 
BYE:
  return status;
}
   
