#include "hmap_common.h"
#include "hmap_struct.h"
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
  register bool *bkt_full = ptr_hmap->bkt_full;

  // some obvious logical checks
  if ( ( newsize <= 0 ) || ( newsize >= UINT_MAX ) )  { go_BYE(-1); }
  if ( newsize < (uint32_t)(HIGH_WATER_MARK * (double)nitems) ) { 
    go_BYE(-1); 
  }
  ptr_hmap->bkts   = calloc(sizeof(bkt_t), newsize);
  ptr_hmap->bkt_full   = calloc(sizeof(bool), newsize);
  ptr_hmap->size   = newsize;
  uint32_t chk_nitems = ptr_hmap->nitems;
  ptr_hmap->nitems = 0;

   // generate a new hash key/seed every time we resize the hash table.
  ptr_hmap->divinfo = fast_div32_init(newsize);
  ptr_hmap->hashkey = mk_hmap_key();

  for ( uint32_t i = 0; i < oldsize; i++) {
    if ( bkt_full[i] == false ) { continue; } // skip empty slots
    // printf("Re-inserting %s \n", (char *)bkts[i].key);
    hmap_key_t key  = bkts[i].key;
    hmap_val_t val  = bkts[i].val;
    status = hmap_insert(ptr_hmap, 
        (const void * const)&key, (const void * const)&val);
    cBYE(status);
  }
  if ( ptr_hmap->nitems != chk_nitems ) { go_BYE(-1); }
  free_if_non_null(bkts);
  free_if_non_null(bkt_full);
BYE:
  return status;
}
