#include "q_incs.h"
#include "hmap_custom_types.h"
#include "inval_copy.h"

hmap_val_t *
inval_copy(
    const hmap_in_val_t * const vin
    )
{
  hmap_val_t * vout = malloc(sizeof(hmap_val_t));
  vout->sum_val = *vin;
  vout->min_val = *vin;
  vout->max_val = *vin;
  vout->cnt = 1; 
  return vout;
}
