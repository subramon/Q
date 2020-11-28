#include "hmap_common.h"
#include "hmap_destroy.h"
void
hmap_destroy(
    hmap_t *ptr_hmap
    )
{
  if ( ptr_hmap == NULL ) { return; }
  free_if_non_null(ptr_hmap->bkts);
  memset(ptr_hmap, '\0', sizeof(hmap_t));
}
