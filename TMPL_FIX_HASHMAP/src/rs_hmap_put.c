// EXTERNAL EXPOSURE
/*
 * rhashmap_put: insert a value given the key.
 *
 * => If the key is already present, return its associated value.
 * => Otherwise, on successful insert, return the given value.
 */
 #include "calc_new_size.h"
 #include "rs_hmap_common.h"
 #include "rs_hmap_struct.h"
 #include "_rs_hmap_resize.h"
 #include "_rs_hmap_insert.h"
 #include "_rs_hmap_put.h"
int
rs_hmap_put(
    ${tmpl}_rs_hmap_t *ptr_hmap, 
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
    status = rs_hmap_resize(ptr_hmap, newsize); cBYE(status);
  }
  status = rs_hmap_insert(ptr_hmap, ptr_key, ptr_val); cBYE(status);
BYE:
  return status;
}
