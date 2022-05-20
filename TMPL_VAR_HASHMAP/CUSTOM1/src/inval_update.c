// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "hmap_custom_types.h"
#include "inval_update.h"

int
inval_update(
    hmap_val_t * dst,
    const hmap_in_val_t * const src
    )
{
  int status = 0;

  if ( dst == NULL ) { go_BYE(-1); }
  if ( src == NULL ) { go_BYE(-1); }
  hmap_in_val_t in_val = *src;

  if ( dst->min_val > in_val ) { dst->min_val = in_val; }
  if ( dst->max_val < in_val ) { dst->min_val = in_val; }
  dst->sum_val += in_val; 
  dst->cnt++;
BYE:
  return status;
}
