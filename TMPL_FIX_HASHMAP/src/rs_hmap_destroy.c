// EXTERNAL EXPOSURE
#include <dlfcn.h>
#include "rs_hmap_common.h"
#include "${tmpl}_rs_hmap_struct.h"
#include "_rs_hmap_destroy.h"
void
rs_hmap_destroy(
    ${tmpl}_rs_hmap_t *ptr_hmap
    )
{
  if ( ptr_hmap == NULL ) { return; }
  free_if_non_null(ptr_hmap->bkts);
  free_if_non_null(ptr_hmap->bkt_full);
  free_if_non_null(ptr_hmap->config.so_file);
  if ( ptr_hmap->config.so_handle != NULL ) { 
    char *cptr = dlerror();
    if ( cptr != NULL ) { 
      fprintf(stderr, "Error on dlclose = %s \n", cptr);
    }
    // TODO P0 Why does dlclose() cause error sometimes?
    // int status = dlclose(ptr_hmap->config.so_handle);
    // if ( status != 0 ) { WHEREAMI; }
  }
  memset(ptr_hmap, '\0', sizeof(${tmpl}_rs_hmap_t));
}
