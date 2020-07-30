//START_INCLUDES
#include "hmap_common.h"
#include "_hmap_types.h"
//STOP_INCLUDES
#include "_hmap_destroy.h"
//START_FOR_CDEF
void
hmap_destroy(
    hmap_t *ptr_hmap
    )
//STOP_FOR_CDEF
{
  if ( ptr_hmap == NULL ) { return; }
  free_if_non_null(ptr_hmap->bkts);
  memset(ptr_hmap, '\0', sizeof(hmap_t));
  // free_if_non_null(ptr_hmap);
}
