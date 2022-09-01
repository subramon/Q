#include "q_incs.h"
#include "rs_hmap_int_struct.h"
#include "bkt_chk.h"
int
bkt_chk(
    const void * const in_bkts,
    uint32_t n
    )
{
  int status = 0;
  if ( in_bkts == NULL ) { go_BYE(-1); }
  if ( n == 0 ) { go_BYE(-1); }
  const bkt_t * const bkts = (const bkt_t * const) in_bkts;

  rs_hmap_val_t zero_val; int valsz = sizeof(rs_hmap_val_t);
  memset(&zero_val, 0, valsz);

  rs_hmap_key_t zero_key; int keysz = sizeof(rs_hmap_key_t);
  memset(&zero_key, 0, keysz);

  for ( uint32_t i = 0; i < n; i++ ) { 
    // if key is 0, val must be 0 
    if ( memcmp(&zero_key, &(bkts[i].key), keysz) != 0 ) {
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) != 0 ) {
        go_BYE(-1);
      }
    }
    else {
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) == 0 ) {
        go_BYE(-1);
      }
    }
  }
BYE:
  return status;
}
