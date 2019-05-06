#include "q_incs.h"
int
// sum_in_range
// min_in_range
// max_in_range
num_in_range(
    int32_t *in_val, // will be NULL for num_in_range
    int32_t *in_lnk,
    uint64_t src_nR,
    int32_t *lb,
    int32_t *ub,
    uint64_t dst_nR,
    uint32_t *dst
    )
{
  int status = 0;
  for ( uint64_t i = 0; i < dst_nR; i++ ) { dst[i] = 0; }
  for ( uint64_t i = 0; i < src_nR; i++ ) { 
    int32_t lnk_val = in_lnk[i];
    for ( uint64_t j = 0; j < dst_nR; j++ ) { 
      if ( ( lnk_val >= lb[j] ) && ( lnk_val <  ub[j] ) )  {
        dst[j] = mcr_add(dst[j], 1); // to substitute
        // dst[j] = mcr_min(dst[j], in_val[i]);
        // dst[j] = mcr_max(dst[j], in_val[i]);
        // dst[j] = mcr_sum(dst[j], in_val[i]);
      }
    }
  }
BYE:
  return status;
}
