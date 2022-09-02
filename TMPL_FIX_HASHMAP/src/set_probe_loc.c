#include <stdint.h>
#include "rs_hmap_common.h"
#include "set_probe_loc.h"
#include "fasthash.h"

uint32_t
set_probe_loc(
    uint32_t hash,
    uint32_t size,
    uint64_t divinfo
    )
{
  uint32_t probe_loc;
  probe_loc = fast_rem32(hash, size, divinfo);
  return probe_loc;
}

