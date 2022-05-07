/*
 * rhashmap_put: insert a value given the key.
 *
 * => If the key is already present, return its associated value.
 * => Otherwise, on successful insert, return the given value.
 */
 #include "hmap_common.h"
 #include "hmap_put.h"
 #include "calc_new_size.h"
 #include "hmap_resize.h"
 #include "hmap_insert.h"
int
hmap_put(
    hmap_t *ptr_hmap, 
    key_t *key, 
    key_t *val,
    void *update_fn_ptr, // function pointer 
    dbg_t *ptr_dbg
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
  status = hmap_insert(ptr_hmap, key, val, update_fn_ptr, ptr_dbg); 
  cBYE(status);
BYE:
  return status;
}
