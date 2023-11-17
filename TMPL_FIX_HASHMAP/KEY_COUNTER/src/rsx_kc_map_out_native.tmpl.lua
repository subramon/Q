return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include "q_macros.h"
#include <string.h>
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  const ${label}_rs_hmap_t * const ptr_H,
  const char * const from,
  uint32_t n_data,
  const uint32_t * const hidx_ptr,
  uint32_t * out_ptr
  );
  ]],
definition = [[
#include "${fn}.h"
int 
${fn}(
  const ${label}_rs_hmap_t * const ptr_H,
  const char * const from,
  uint32_t n_data,
  const uint32_t * const hidx_ptr,
  uint32_t * out_ptr
  )
{
  int status = 0;
  if ( from == NULL ) { go_BYE(-1); } 
  uint32_t size = ptr_H->size;
  if ( strcmp(from, "guid") == 0 ) { 
    for ( uint32_t i = 0; i < n_data; i++ ) {
      uint32_t hash_loc = hidx_ptr[i];
      if ( ( hash_loc >= size ) || ( ptr_H->bkt_full[hash_loc] == false ) ) { 
        out_ptr[i] = 0;
      }
      else { 
        out_ptr[i] = ptr_H->bkts[hash_loc].val.guid;
      }
    }
  }
  else if ( strcmp(from, "count") == 0 ) { 
    for ( uint32_t i = 0; i < n_data; i++ ) {
      uint32_t hash_loc = hidx_ptr[i];
      if ( ( hash_loc >= size ) || ( ptr_H->bkt_full[hash_loc] == false ) ) { 
        out_ptr[i] = 0;
      }
      else { 
        out_ptr[i] = ptr_H->bkts[hash_loc].val.count;
      }
    }
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
]],
}
