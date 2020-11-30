#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rdtsc.h"
#include "hmap_common.h"
#include "hmap_struct.h"
#include "hmap_aux.h"

uint32_t
mk_hmap_key(
    void
    )
{
  uint64_t r1 = random() ^ RDTSC();
  uint64_t r2 = random() ^ RDTSC();
  return (uint32_t)( r1 | ( r2 << 32 )  );
}

uint32_t
set_hash(
    const void *const key,
    uint16_t len,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    )
{
  uint32_t hash;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->hash == 0 ) ) { 
    hash = murmurhash3(key, len, ptr_hmap->hashkey);
  }
  else { 
    hash = ptr_dbg->hash;
  }
  return hash;
}
//----------------------------------------------
uint32_t
set_probe_loc(
    uint32_t hash,
    hmap_t *ptr_hmap,
    dbg_t *ptr_dbg
    )
{
  uint32_t probe_loc;
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->probe_loc == 0 ) ) { 
    probe_loc = fast_rem32(hash, size, divinfo);
  }
  else {
    probe_loc = ptr_dbg->probe_loc;
  }
  return probe_loc;
}
