#include "rs_hmap_struct.h"
#include "rsx_key_ordr.h"
int
rsx_key_ordr(
    const void *in1, 
    const void *in2
    )
{
  const rs_hmap_kv_t  *u1 = (const rs_hmap_kv_t *)in1;
  const rs_hmap_kv_t  *u2 = (const rs_hmap_kv_t *)in2;
  return 1;  // Some junk retun value. Needs to be done properly
}
