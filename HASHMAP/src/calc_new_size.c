#include "hmap_common.h"
#include "calc_new_size.h"
/* Checks whether resize is needed. If so, calculates newsize */
/* Resize needed when occupancy is too high */
//START_FUNC_DECL
int
calc_new_size(
    uint32_t nitems, 
    uint32_t minsize, 
    uint32_t maxsize, 
    uint32_t size, 
    uint32_t *ptr_newsize,
    bool *ptr_resize
    )
{
  int status = 0;
  *ptr_resize = false;
  uint64_t newsize = 0;
  uint64_t threshold;
  // If the load factor is more than the threshold, then resize.
  threshold = (uint64_t)(HIGH_WATER_MARK * (double)size);
  // TODO P4 Clean up the following code 
  if ( nitems > threshold ) { 
    *ptr_resize = true;
    for ( ; nitems > threshold; ) { 
      /*
       * Grow the hash table by doubling its size, but with
       * a limit of MAX_GROWTH_STEP.
       */
      uint64_t grow_limit = size + MAX_GROWTH_STEP;
      newsize = MIN(size << 1, grow_limit);
      threshold = (uint64_t)(0.85 * (double)newsize);
    }
  }
  double max_newsize = UINT_MAX * 0.85;
  if ( newsize > max_newsize ) { go_BYE(-1); }
  if ( newsize > maxsize ) { status = -1; goto BYE; }
  *ptr_newsize = newsize;
BYE:
  return status;
}
