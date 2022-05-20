#include "q_incs.h"
#include "hmap_custom_types.h"
#include "val_chk.h"

bool
val_chk(
    const hmap_val_t * const vin
    )
{
  if ( vin == NULL ) { return false; }
  if ( vin->cnt <= 0 ) { return false; }
  return true;
}
