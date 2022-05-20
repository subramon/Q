#include "hmap_common.h"
#include "hmap_destroy.h"
void
hmap_destroy(
    hmap_t *ptr_hmap
    )
{
  if ( ptr_hmap == NULL ) { return; }
  if ( ptr_hmap->bkts != NULL ) { 
    for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
      key_free(ptr_hmap->bkts[i].key);
      val_free(ptr_hmap->bkts[i].val);
      memset(ptr_hmap->bkts+i, 0, sizeof(bkt_t));
    }
  }
  free_if_non_null(ptr_hmap->bkts);
  memset(ptr_hmap, '\0', sizeof(hmap_t));
}
