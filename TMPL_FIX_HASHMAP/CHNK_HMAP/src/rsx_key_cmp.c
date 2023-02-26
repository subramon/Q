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
  if ( ( ptr_k1->vctr_uqid == ptr_k2->vctr_uqid ) &&
       ( ptr_k1->${tmpl}_idx  == ptr_k2->${tmpl}_idx ) ) {
    return true;
  }
  else {
    return false;
  }
}
