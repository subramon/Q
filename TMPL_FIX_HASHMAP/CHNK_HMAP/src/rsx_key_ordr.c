#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_key_ordr.h"
int
rsx_key_ordr(
    const void *in1, 
    const void *in2
    )
{
  const ${tmpl}_rs_hmap_kv_t  *u1 = (const ${tmpl}_rs_hmap_kv_t *)in1;
  const ${tmpl}_rs_hmap_kv_t  *u2 = (const ${tmpl}_rs_hmap_kv_t *)in2;
  if ( u1->key.vctr_uqid < u2->key.vctr_uqid ) { 
    return -1;
  }
  else if ( u1->key.vctr_uqid > u2->key.vctr_uqid ) { 
    return 1;
  }
  else {
    if ( u1->key.${tmpl}_idx < u2->key.${tmpl}_idx ) { 
      return -1;
    }
    else {
      return 1;
    }
  }
}
