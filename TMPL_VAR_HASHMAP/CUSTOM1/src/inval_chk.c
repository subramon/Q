#include "q_incs.h"
#include "hmap_custom_types.h"
#include "inval_chk.h"

bool
inval_chk(
    const hmap_in_val_t * const vin
    )
{
  // Not much of a check 
  if ( vin == NULL ) { return false; }
  return true;
}
