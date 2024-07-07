#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_key_cmp.h"
//START_FUNC_DECL
bool
chnk_rs_hmap_key_cmp(
    const chnk_rs_hmap_key_t *const ptr_k1,
    const chnk_rs_hmap_key_t *const ptr_k2
    )
//STOP_FUNC_DECL
{
  if ( ( ptr_k1->vctr_uqid == ptr_k2->vctr_uqid ) &&
       ( ptr_k1->chnk_idx  == ptr_k2->chnk_idx ) ) {
    return true;
  }
  else {
    return false;
  }
}
