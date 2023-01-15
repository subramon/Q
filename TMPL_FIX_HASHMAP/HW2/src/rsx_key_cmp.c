#include "rs_hmap_struct.h"
#include "rsx_key_cmp.h"
bool
rsx_key_cmp(
    const void *const in_ptr_k1,
    const void *const in_ptr_k2
    )
{
  const hw2_rs_hmap_key_t *const ptr_k1 = (const hw2_rs_hmap_key_t * const)in_ptr_k1;
  const hw2_rs_hmap_key_t *const ptr_k2 = (const hw2_rs_hmap_key_t * const)in_ptr_k2;
  if ( ptr_k1->f4 == ptr_k2->f4 ) { return true; } else { return false; }
}
