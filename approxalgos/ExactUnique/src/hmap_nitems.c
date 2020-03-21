#include "hmap_common.h"
#include "hmap_types.h"
#include "hmap_nitems.h"
int 
hmap_nitems(
    hmap_t *ptr_hmap,
    uint32_t *ptr_n,
    bool *ptr_is_approx
    )
{
  int status = 0;
  if ( ptr_hmap == NULL ) { go_BYE(-1); }
  *ptr_is_approx = ptr_hmap->is_approx;
  uint32_t n = ptr_hmap->nitems;
  if ( ptr_hmap->has_zero ) { n++; }
  *ptr_n = n;
BYE:
  return status;
}
