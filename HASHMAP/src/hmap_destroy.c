#include "hmap_common.h"
#include "hmap_destroy.h"
void
hmap_destroy(
    hmap_t *ptr_hmap
    )
{
  if ( ptr_hmap == NULL ) { return; }
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    free_if_non_null(ptr_hmap->bkts[i].key);
  }
  free_if_non_null(ptr_hmap->bkts);
  memset(ptr_hmap, '\0', sizeof(hmap_t));
}
