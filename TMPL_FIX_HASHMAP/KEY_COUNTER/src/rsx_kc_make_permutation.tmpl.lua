return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include "q_macros.h"
#include <string.h>
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  char **data, // [num_keys][nitems]
  uint32_t *widths, // [num_keys] 
  uint32_t nitems,
  uint64_t *permutation // [nitems]
  );
  ]],
definition = [[
#include "${fn}.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  char **data, // [num_keys][nitems]
  uint32_t *widths, // [num_keys] 
  uint32_t nitems,
  uint64_t *permutation // [nitems]
  )
{
  int status = 0;
  for ( uint32_t i = 0; i < nitems; i++ ) {
    ${label}_rs_hmap_key_t key; memset(&key, 0, sizeof(key));
${comment1}  memcpy(&(key.key1), data[0]+(i*widths[0]), sizeof(key.key1));
${comment2}  memcpy(&(key.key2), data[1]+(i*widths[1]), sizeof(key.key2));
${comment3}  memcpy(&(key.key3), data[2]+(i*widths[2]), sizeof(key.key3));
${comment4}  memcpy(&(key.key4), data[3]+(i*widths[3]), sizeof(key.key4));
    bool is_found; uint32_t where_found;
    ${label}_rs_hmap_val_t val; memset(&val, 0, sizeof(val));
    status = ptr_H->get(ptr_H, &key, &val, &is_found, &where_found);
    cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    permutation[i] = val.cum_count + val.run_count;
    ptr_H->bkts[where_found].val.run_count++; 
#ifdef DEBUG
    if ( val.guid == 0 ) { go_BYE(-1); }
    if ( val.guid > ptr_H->nitems ) { go_BYE(-1); }
#endif
  }
BYE:
  return status;
}
]],
}
