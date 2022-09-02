#include <stdint.h>
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
// #include "set_probe_loc.h"
#include "fasthash.h"

uint32_t
set_probe_loc(
    uint32_t hash,
    rs_hmap_t *ptr_hmap
    )
{
  uint32_t probe_loc;
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;
  probe_loc = fast_rem32(hash, size, divinfo);
  return probe_loc;
}

