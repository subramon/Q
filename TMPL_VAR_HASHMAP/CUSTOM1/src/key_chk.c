#include "q_incs.h"
#include "hmap_custom_types.h"
#include "key_chk.h"

bool
key_chk(
    const hmap_key_t * const kin
    )
{
  if ( kin == NULL ) { return false; }
  if ( kin->str_val == NULL ) { return false; }
  if ( strlen(kin->str_val) != kin->str_len ) { return false;}
  return true;
}
