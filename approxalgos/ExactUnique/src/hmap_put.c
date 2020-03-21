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
    uint64_t  key, 
    uint32_t  hash
    )
{
  int status = 0;
  uint32_t newsize; bool resize = false;

  if ( ptr_hmap->nitems > (double)ptr_hmap->size * HIGH_WATER_MARK ) {
    status = calc_new_size(ptr_hmap->nitems, ptr_hmap->minsize, 
    ptr_hmap->maxsize,ptr_hmap->size, &newsize, &resize);
    if ( status < 0 ) { 
      ptr_hmap->is_approx = true; 
      status = -1; goto BYE;
    }
  }
  if ( resize ) { 
    status = hmap_resize(ptr_hmap, newsize); cBYE(status);
  }
  status = hmap_insert(ptr_hmap, key, hash); cBYE(status);
BYE:
  return status;
}
