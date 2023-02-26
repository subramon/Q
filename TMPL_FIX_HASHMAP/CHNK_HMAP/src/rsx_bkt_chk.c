#include "q_incs.h"
#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_bkt_chk.h"
int
rsx_bkt_chk(
    const void * const in_bkts,
    uint32_t n
    )
{
  int status = 0;
  if ( in_bkts == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }
  const ${tmpl}_rs_hmap_bkt_t * const bkts = (const ${tmpl}_rs_hmap_bkt_t * const) in_bkts;
  ${tmpl}_rs_hmap_val_t zero_val; int valsz = sizeof(${tmpl}_rs_hmap_val_t);
  memset(&zero_val, 0, valsz);
  for ( uint32_t i = 0; i < n; i++ ) { 
    if ( bkts[i].key.vctr_uqid == 0 ) {  // unused
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) != 0 ) {
        go_BYE(-1);
      }
    }
    else {
      ${tmpl}_rs_hmap_val_t val = bkts[i].val;
      if ( val.num_elements > val.size ) { go_BYE(-1); }
      if ( val.num_elements == 0       ) { go_BYE(-1); }
      if ( val.l2_exists  == false ) { 
        if ( val.l1_mem == NULL ) { go_BYE(-1); }
      }
    }
  }
BYE:
  return status;
}
