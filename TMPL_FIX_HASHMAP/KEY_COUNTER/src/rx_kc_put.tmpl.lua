return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include <string.h>
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  char **data,
  uint32_t *widths,
  uint32_t nitems
  );
]],
definition = [[
#include "${label}_rsx_kc_put.h"
int 
${fn}(
  ${label}_rs_hmap_t *ptr_H,
  char **data,
  uint32_t *widths,
  uint32_t nitems
  )
{
  int status = 0;
  for ( uint32_t i = 0; i < nitems; i++ ) {
    ${tmpl}_rs_hmap_key_t key;
    memset(&key, 0, sizeof(key));
${comment1}  memcpy(&(key.key1), data[0]+(i*widths[0]), sizeof(key.key1));
${comment2}  memcpy(&(key.key2), data[1]+(i*widths[1]), sizeof(key.key2));
${comment3}  memcpy(&(key.key2), data[1]+(i*widths[1]), sizeof(key.key2));
${comment4}  memcpy(&(key.key2), data[1]+(i*widths[1]), sizeof(key.key2));
    status = H.put(ptr_H, &key, &val); cBYE(status);
    bool is_found; uint32_t where_found;
#ifdef DEBUG
    status = ptr_H->get(ptr_H, &key, &chk_val, &is_found, &where_found);
    cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
#endif
  }
BYE:
  return status;
}
]],
}
