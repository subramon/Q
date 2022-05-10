/*
 * rhashmap_put: insert a value given the key.
 *
 * => If the key is already present, return its associated value.
 * => Otherwise, on successful insert, return the given value.
 */
 #include "hmap_common.h"
 #include "hmap_struct.h"
 #include "hmap_put.h"
 #include "calc_new_size.h"
 #include "hmap_resize.h"
 #include "hmap_insert.h"
int
hmap_put(
    hmap_t *ptr_hmap, 
    const void  * const ptr_key, 
    const void * const ptr_val
    )
{
  int status = 0;
  uint32_t newsize; bool resize = false;
  uint64_t threshold = (uint64_t)(HIGH_WATER_MARK * (double)ptr_hmap->size);

  if ( ptr_hmap->nitems > threshold ) { 
    status = calc_new_size(ptr_hmap->nitems, ptr_hmap->config.max_size, 
        ptr_hmap->size, &newsize, &resize);
    cBYE(status);
  }
  if ( resize ) { 
    status = hmap_resize(ptr_hmap, newsize); cBYE(status);
  }
  status = hmap_insert(ptr_hmap, ptr_key, ptr_val); cBYE(status);
BYE:
  return status;
}
