#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rsx_set_hash.h"
#include "fasthash.h"

uint32_t
rsx_set_hash(
    const void * const in_ptr_key,
    const void * const in_ptr_hmap
    )
{
  uint32_t hash;
  const rs_hmap_key_t * const ptr_key = 
    (const rs_hmap_key_t * const) in_ptr_key;
  const rs_hmap_t * const ptr_hmap = 
    (const rs_hmap_t * const) in_ptr_hmap;
    // hash = murmurhash3(key, len, ptr_hmap->hashkey);
  hash = fasthash32(ptr_key, sizeof(rs_hmap_key_t), ptr_hmap->hashkey);
  return hash;
}
