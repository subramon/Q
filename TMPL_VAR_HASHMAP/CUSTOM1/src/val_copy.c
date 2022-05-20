#include "q_incs.h"
#include "hmap_custom_types.h"
#include "val_copy.h"

hmap_val_t *
val_copy(
    const hmap_val_t * const vin
    )
{
  if ( vin == NULL ) { WHEREAMI; return NULL; }
  hmap_val_t * vout = malloc(sizeof(hmap_val_t));
  vout->sum_val = vin->sum_val;
  vout->min_val = vin->min_val;
  vout->max_val = vin->max_val;
  vout->cnt     = vin->cnt;
  return vout;
}
