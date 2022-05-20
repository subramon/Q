// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "hmap_custom_types.h"
#include "val_update.h"

int
val_update(
    hmap_val_t * dst,
    const hmap_val_t * const src
    )
{
  int status = 0;

  if ( dst == NULL ) { go_BYE(-1); }
  if ( src == NULL ) { go_BYE(-1); }

  if ( dst->min_val > src->min_val ) { dst->min_val = src->min_val; }
  if ( dst->max_val < src->max_val ) { dst->min_val = src->max_val; }
  dst->sum_val += src->sum_val;
  dst->cnt++;
BYE:
  return status;
}
