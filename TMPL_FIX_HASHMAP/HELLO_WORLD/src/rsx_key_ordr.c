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
  rs_hmap_key_t k1 = u1->key;
  rs_hmap_key_t k2 = u2->key;
  if ( k1 < k2 ) { 
    return -1;
  }
  else {
    return 1;
  }
}
