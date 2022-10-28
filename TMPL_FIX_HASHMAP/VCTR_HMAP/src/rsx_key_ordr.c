#include "vctr_rs_hmap_struct.h"
#include "rsx_key_ordr.h"
int
rsx_key_ordr(
    const void *in1, 
    const void *in2
    )
{
  const vctr_rs_hmap_kv_t  *u1 = (const vctr_rs_hmap_kv_t *)in1;
  const vctr_rs_hmap_kv_t  *u2 = (const vctr_rs_hmap_kv_t *)in2;
  if ( u1->key < u2->key ) { 
    return -1;
  }
  else {
    return 1;
  }
}
