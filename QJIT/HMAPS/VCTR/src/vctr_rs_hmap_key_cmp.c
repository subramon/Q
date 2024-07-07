#include "vctr_rs_hmap_key_type.h"
#include "vctr_rs_hmap_key_cmp.h"
//START_FUNC_DECL
bool
vctr_rs_hmap_key_cmp(
    const vctr_rs_hmap_key_t *const ptr_k1,
    const vctr_rs_hmap_key_t *const ptr_k2
    )
//STOP_FUNC_DECL
{
  if ( *ptr_k1 == *ptr_k2 ) { return true; } else { return false; }
}
