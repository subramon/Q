#include "q_incs.h"
#include "q_macros.h"
#include "rs_hmap_struct.h"
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
  const bkt_t * const bkts = (const bkt_t * const) in_bkts;
  vctr_rs_hmap_val_t zero_val; int valsz = sizeof(vctr_rs_hmap_val_t);
  memset(&zero_val, 0, valsz);
  for ( uint32_t i = 0; i < n; i++ ) { 
    if ( bkts[i].key == 0 ) {  // unused
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) != 0 ) {
        go_BYE(-1);
      }
    }
    else {
      vctr_rs_hmap_val_t val = bkts[i].val;
      if ( ( val.qtype == Q0 ) || 
           ( val.qtype >= NUM_QTYPES ) ) { 
        go_BYE(-1);
      }
      if ( val.num_elements == 0 ) { 
        if ( val.num_chunks != 0 ) { go_BYE(-1); }
      }
      if ( val.num_chunks == 0 ) { 
        if ( val.num_elements != 0 ) { go_BYE(-1); }
      }
    }
  }
BYE:
  return status;
}
