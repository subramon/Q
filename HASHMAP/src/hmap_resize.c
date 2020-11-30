#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_chk.h"
#include "hmap_insert.h"
#include "hmap_resize.h"

int
hmap_resize(
    hmap_t *ptr_hmap, 
    size_t newsize
    )
{
  int status = 0;
  if ( ptr_hmap == NULL ) { go_BYE(-1); }
  const size_t oldsize = ptr_hmap->size;
  const size_t nitems  = ptr_hmap->nitems;
  register bkt_t *bkts = ptr_hmap->bkts;

  // some obvious logical checks
  if ( ( newsize <= 0 ) || ( newsize >= UINT_MAX ) )  { go_BYE(-1); }
  if ( newsize < (uint32_t)(HIGH_WATER_MARK * (double)nitems) ) { 
    go_BYE(-1); 
  }
  ptr_hmap->bkts   = calloc(sizeof(bkt_t), newsize);
  ptr_hmap->size   = newsize;
  uint32_t chk_nitems = ptr_hmap->nitems;
  ptr_hmap->nitems = 0;

   // generate a new hash key/seed every time we resize the hash table.
  ptr_hmap->divinfo = fast_div32_init(newsize);
  ptr_hmap->hashkey = mk_hmap_key();

  bool malloc_key = false;
  for ( uint32_t i = 0; i < oldsize; i++) {
    if ( bkts[i].key == 0 ) { continue; } // skip empty slots
    // printf("Re-inserting %s \n", (char *)bkts[i].key);
    status = hmap_insert(ptr_hmap, bkts[i].key, bkts[i].len, 
        malloc_key, bkts[i].val, NULL);
    cBYE(status);
  }
  if ( ptr_hmap->nitems != chk_nitems ) { go_BYE(-1); }
  free_if_non_null(bkts);
BYE:
  return status;
}
