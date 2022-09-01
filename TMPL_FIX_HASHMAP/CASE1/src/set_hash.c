#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "rs_hmap_int_struct.h"
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "set_hash.h"
#include "fasthash.h"

uint32_t
set_hash(
    const rs_hmap_key_t * const ptr_key,
    const rs_hmap_t * const ptr_hmap
    )
{
  uint32_t hash;
    // hash = murmurhash3(key, len, ptr_hmap->hashkey);
  hash = fasthash32(ptr_key, sizeof(rs_hmap_key_t), ptr_hmap->hashkey);
  return hash;
}
