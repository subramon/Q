#include "q_incs.h"
int
foo(
    const ${pk_type} * const dst_pk,
    const ${tim_type} * const dst_t_start, 
    const ${tim_type} * const dst_t_stop, 
    uint32_t dst_n,
    ${val_type} *dst_val,
    uint8_t *nn_dst_val,

    const uint64_t src_pk,
    const ${tim_type} src_t_start, 
    const ${tim_type} src_t_stop, 
    uint32_t *ptr_start_src_idx, // 0 for first invocation
    uint32_t src_n,
    ${val_type} *src_val
   )
{
  int status = 0;

  uint32_t src_idx = *ptr_start_src_idx;
  for ( uint32_t dst_idx = 0; dst_idx < dst_n; dst_idx++ ) { 
    if ( src_idx >= src_n ) { break; }
    ${pk_type} l_dst_pk = dst_pk[dst_idx];
    ${pk_type} l_src_pk = src_pk[src_idx];
    if ( l_dst_pk  == l_src_pk ) { 
      dst_val[dst_idx] = srx_val[src_idx];
      nn_dst_val[dst_idx] = 1;
      dst_idx++;
    }
    else if ( l_dst_pk > l_src_pk ) { 
      dst_idx++;
    else { // ( l_dst_pk < l_src_pk ) 
      src_idx++;
    }
  }
  *ptr_start_src_idx = src_idx;
BYE:
  return status;
}