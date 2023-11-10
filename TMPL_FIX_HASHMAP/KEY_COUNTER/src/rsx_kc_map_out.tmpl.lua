return require 'Q/UTILS/lua/code_gen' { 
  declaration = [[
#include "q_macros.h"
#include <string.h>
#include "${label}_rs_hmap_struct.h"
int 
${fn}(
  const ${label}_rs_hmap_t * const ptr_H,
  const uint32_t * const from_ptr, // [n_data]
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
  const uint32_t * const from_ptr, // [n_data]
  uint32_t n_data,
  const uint32_t * const hidx_ptr,
  uint32_t * out_ptr
  )
{
  int status = 0;
  if ( from_ptr == NULL ) { go_BYE(-1); } 
  uint32_t size = ptr_H->size;
  for ( uint32_t i = 0; i < n_data; i++ ) {
    uint32_t hash_loc = hidx_ptr[i];
    if ( hash_loc >= size ) { go_BYE(-1); }
    out_ptr[i] = from_ptr[hash_loc];
  }
BYE:
  return status;
}
]],
}
