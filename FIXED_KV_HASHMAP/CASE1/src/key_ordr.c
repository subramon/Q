#include "hmap_struct.h"
#include "key_ordr.h"
int
key_ordr(
    const void *in1, 
    const void *in2
    )
{
  const hmap_kv_t  *u1 = (const hmap_kv_t *)in1;
  const hmap_kv_t  *u2 = (const hmap_kv_t *)in2;
  uint64_t k1 = u1->key;
  uint64_t k2 = u2->key;
  if ( k1 < k2 ) { 
    return -1;
  }
  else {
    return 1;
  }
}
