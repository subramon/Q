#include <string.h>
#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_key_cmp.h"
//START_FUNC_DECL
bool
rsx_key_cmp(
    const void *const in_ptr_k1,
    const void *const in_ptr_k2
    )
//STOP_FUNC_DECL
{
  const ${tmpl}_rs_hmap_key_t *const ptr_k1 = (const ${tmpl}_rs_hmap_key_t * const)in_ptr_k1;
  const ${tmpl}_rs_hmap_key_t *const ptr_k2 = (const ${tmpl}_rs_hmap_key_t * const)in_ptr_k2;
  if ( memcmp(ptr_k1, ptr_k2, sizeof(${tmpl}_rs_hmap_key_t)) == 0 ) {
    return true;
  }
  else {
    return false;
  }
}
