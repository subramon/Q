return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include "q_macros.h"
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  uint64_t *ptr_sum
  );
]],
definition = [[
#include "${label}_rsx_kc_sum_count.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  uint64_t *ptr_sum
  )
{
  int status = 0;
  uint64_t sum_count = 0; 
  for ( uint32_t i = 0; i < ptr_H->size; i++ ) {
    if ( ptr_H->bkt_full[i] == false ) { continue; }
    sum_count += ptr_H->bkts[i].val.count;
  }
  *ptr_sum = sum_count;
BYE:
  return status;
}
]],
}
