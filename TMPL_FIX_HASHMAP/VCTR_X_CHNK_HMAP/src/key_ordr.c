#include "rs_hmap_int_struct.h"
#include "key_ordr.h"
int
key_ordr(
    const void *in1, 
    const void *in2
    )
{
  const rs_hmap_kv_t  *u1 = (const rs_hmap_kv_t *)in1;
  const rs_hmap_kv_t  *u2 = (const rs_hmap_kv_t *)in2;
  rs_hmap_key_t k1 = u1->key;
  rs_hmap_key_t k2 = u2->key;
  if ( k1.vctr_uqid < k2.vctr_uqid ) { 
    return -1;
  }
  else if ( k1.vctr_uqid > k2.vctr_uqid ) { 
    return 1;
  }
  else {
    if ( k1.chnk_idx < k2.chnk_idx ) { 
      return -1;
    }
    else {
      return 1;
    }
  }
}
