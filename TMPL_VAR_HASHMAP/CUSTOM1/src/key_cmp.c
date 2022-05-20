#include "q_incs.h"
#include "hmap_custom_types.h"
#include "key_cmp.h"

bool
key_cmp(
    const hmap_key_t * const ptr_key1,
    const hmap_key_t * const ptr_key2
    )
{
  if ( strcmp(ptr_key1->str_val, ptr_key2->str_val) == 0 ) { 
    return true;
  }
  else {
    return false;
  }
}
