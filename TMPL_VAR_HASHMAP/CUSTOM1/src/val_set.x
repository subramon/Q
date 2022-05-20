// set the value 
#include "q_incs.h"
#include "q_macros.h"
#include "hmap_custom_types.h"
#include "val_set.h"

int
val_set(
    hmap_val_t **ptr_dst,
    const hmap_in_val_t * const src
    )
{
  int status = 0;
  hmap_val_t *dst = NULL;

  if ( src == NULL ) { go_BYE(-1); }
  dst = malloc(1 * sizeof(hmap_val_t));
  return_if_malloc_failed(dst);
  memset(dst, 0,  1 * sizeof(hmap_val_t));
  dst->agg_val = *src;
  *ptr_dst = dst;
BYE:
  return status;
}
