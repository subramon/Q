#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_key_cmp.h"
bool
rsx_key_cmp(
    const void *const in_ptr_k1,
    const void *const in_ptr_k2
    )
{
  const ${tmpl}_rs_hmap_key_t *const ptr_k1 = (const ${tmpl}_rs_hmap_key_t * const)in_ptr_k1;
  const ${tmpl}_rs_hmap_key_t *const ptr_k2 = (const ${tmpl}_rs_hmap_key_t * const)in_ptr_k2;
  ${tmpl}_rs_hmap_key_t k1 = *ptr_k1;
  ${tmpl}_rs_hmap_key_t k2 = *ptr_k2;
  if ( k1 == k2 ) { return true; } else { return false; }
}
