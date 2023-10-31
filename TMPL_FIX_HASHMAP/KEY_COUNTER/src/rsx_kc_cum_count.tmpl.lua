return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include "q_macros.h"
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  uint64_t *cum_count, // [ptr_H->size] 
  uint64_t *ptr_sum
  );
]],
definition = [[
#include "${label}_rsx_kc_cum_count.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  uint64_t *cum_count, // [ptr_H->size] 
  uint64_t *ptr_sum
  )
{
  int status = 0;
  uint64_t sum_count = 0; 
  for ( uint32_t i = 0; i < ptr_H->size; i++ ) {
    if ( ptr_H->bkt_full[i] == false ) { 
      cum_count[i] = 0; 
    }
    else {
      uint32_t l_count = ptr_H->bkts[i].val.count;
      cum_count[i] = sum_count;
      sum_count += l_count;
    }
  }
  *ptr_sum = sum_count;
BYE:
  return status;
}
]],
}
