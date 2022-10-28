#include "q_incs.h"
#include "isby_I8_I4.h"

int
isby_I8_I4(
    const int64_t *const src_lnk,
    const int32_t *const src_val,
    uint32_t src_len,
    const int64_t *const dst_lnk,
    int32_t * restrict dst_val,
    bool * restrict nn_dst_val,
    uint32_t dst_len,
    uint32_t *ptr_src_idx,
    uint32_t *ptr_dst_idx
    )
{
  int status = 0;
  uint32_t src_idx = *ptr_src_idx;
  uint32_t dst_idx = *ptr_dst_idx;
  while ( ( src_idx < src_len ) && ( dst_idx < dst_len ) ) {
    int64_t l_src_lnk = src_lnk[src_idx];
    int64_t l_dst_lnk = dst_lnk[dst_idx];
    if ( l_src_lnk == l_dst_lnk ) {
      int32_t l_src_val = src_val[src_idx];
      dst_val[dst_idx] = l_src_val;
      nn_dst_val[dst_idx] = true;
      dst_idx++;
    }
    else if ( l_src_lnk < l_dst_lnk ) {
      src_idx++;
    }
    else {
      nn_dst_val[dst_idx] = false;
      dst_idx++;
    }
  }
  *ptr_src_idx = src_idx;
  *ptr_dst_idx = dst_idx;
BYE:
  return status;
}
