#include "rs_hmap_int_struct.h"
#include "key_cmp.h"
bool
key_cmp(
    const void *const in_ptr_k1,
    const void *const in_ptr_k2
    )
{
  const rs_hmap_key_t *const ptr_k1 = (const rs_hmap_key_t * const)in_ptr_k1;
  const rs_hmap_key_t *const ptr_k2 = (const rs_hmap_key_t * const)in_ptr_k2;
  rs_hmap_key_t k1 = *ptr_k1;
  rs_hmap_key_t k2 = *ptr_k2;
  if ( k1 == k2 ) { return true; } else { return false; }
}
