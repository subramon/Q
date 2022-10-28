// EXTERNAL EXPOSURE
#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_destroy.h"
void
rs_hmap_destroy(
    rs_hmap_t *ptr_hmap
    )
{
  if ( ptr_hmap == NULL ) { return; }
  free_if_non_null(ptr_hmap->bkts);
  free_if_non_null(ptr_hmap->bkt_full);
  if ( ptr_hmap->config.so_handle != NULL ) { 
    int status = dlclose(ptr_hmap->config.so_handle);
    if ( status != 0 ) { WHEREAMI; }
  }
  free_if_non_null(ptr_hmap->config.so_file);
  memset(ptr_hmap, '\0', sizeof(rs_hmap_t));
}
