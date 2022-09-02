#include "rsx_types.h"
#include "rsx_key_cmp.h"
bool
rsx_key_cmp(
    const void *const in_ptr_k1,
    const void *const in_ptr_k2
    )
{
  const vctr_rs_hmap_key_t *const ptr_k1 = (const vctr_rs_hmap_key_t * const)in_ptr_k1;
  const vctr_rs_hmap_key_t *const ptr_k2 = (const vctr_rs_hmap_key_t * const)in_ptr_k2;
  if ( *ptr_k1 == *ptr_k2 ) { return true; } else { return false; }
}
