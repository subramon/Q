#include "rsx_types.h"
#include "rsx_val_update.h"
int 
rsx_val_update(
    void *in_ptr_v1,
    const void *const in_ptr_v2
    )
{
  int status = 0;
  rs_hmap_val_t *ptr_v1 = (rs_hmap_val_t * )in_ptr_v1;
  const rs_hmap_val_t *const ptr_v2 = (const rs_hmap_val_t * const)in_ptr_v2;
  rs_hmap_val_t v1 = *ptr_v1;
  rs_hmap_val_t v2 = *ptr_v2;
  *ptr_v1 = v1 + v2;
  return status;
}
