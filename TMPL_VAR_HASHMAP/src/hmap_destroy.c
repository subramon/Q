#include "hmap_common.h"
#include "hmap_destroy.h"
void
hmap_destroy(
    hmap_t *H
    )
{
  if ( H == NULL ) { return; }
  if ( H->bkts != NULL ) { 
    for ( uint32_t i = 0; i < H->size; i++ ) { 
      H->key_free(H->bkts[i].key);
      H->val_free(H->bkts[i].val);
      memset(H->bkts+i, 0, sizeof(bkt_t));
    }
  }
  free_if_non_null(H->bkts);
  memset(H, '\0', sizeof(hmap_t));
}
