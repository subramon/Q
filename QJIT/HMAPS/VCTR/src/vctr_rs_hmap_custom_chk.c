#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_custom_chk.h"

/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
//START_FUNC_DECL
int
vctr_rs_hmap_custom_chk(
    const vctr_rs_hmap_t * const H
    )
//STOP_FUNC_DECL
{
  int status = 0;

  if ( H == NULL ) { go_BYE(-1); }

  const vctr_rs_hmap_bkt_t * const bkts = H->bkts;
  if ( bkts == NULL ) { go_BYE(-1); }

  const bool * const bkt_full = H->bkt_full;
  if ( bkt_full == NULL ) { go_BYE(-1); }

  uint32_t sz = H->size;
  if ( sz == 0 ) { go_BYE(-1); }

  uint32_t n = H->nitems;
  if ( n == 0 ) { return status; } // early exit

  vctr_rs_hmap_val_t zero_val; 
  uint32_t valsz = sizeof(vctr_rs_hmap_val_t);
  memset(&zero_val, 0, valsz);

  vctr_rs_hmap_key_t zero_key; 
  uint32_t keysz = sizeof(vctr_rs_hmap_key_t);
  memset(&zero_key, 0, keysz);

  for ( uint32_t i = 0; i < sz; i++ ) {
    if ( bkt_full[i] ) {
      vctr_rs_hmap_key_t key; 
      memset(&zero_key, 0, sizeof(vctr_rs_hmap_key_t));
      key = bkts[i].key;

      if ( key == 0 ) { go_BYE(-1); } 
      //--------------------------------------------
      vctr_rs_hmap_val_t val; 
      memset(&zero_val, 0, sizeof(vctr_rs_hmap_val_t));
      val = bkts[i].val;

      // name must be null terminated 
      if (val.name[MAX_LEN_VCTR_NAME] != '\0' ) { go_BYE(-1); }
      if ( val.num_elements == 0       ) { go_BYE(-1); }
      if ( val.num_chnks == 0       ) { go_BYE(-1); }
      // max_chnk_idx == num_chnks-1 except (possibly) when memo_len >= 1
      if ( val.memo_len < 0 ) {
        if ( val.max_chnk_idx != val.num_chnks-1 ) { go_BYE(-1); }
      }
      else {
        // TODO Place assertion here
      }
      if ( val.qtype == QF ) { go_BYE(-1); }
      if ( val.qtype == Q0 ) { go_BYE(-1); }
      // Unfortunately, we have some special casing to do here
      if ( val.qtype == B1 ) { 
        if  ( val.width != 0 ) { go_BYE(-1); }
      }
      else if ( val.qtype != SC ) { 
        uint32_t width = get_width_c_qtype(val.qtype);
        if ( width == 0 ) { go_BYE(-1); }
        if ( val.width != width ) { go_BYE(-1); }
      }
      else {
        if ( val.width < 2 ) { go_BYE(-1); }
      }
      // TODO Lots of checks based on other struct elements to be written

      if ( val.num_readers > 0 ) { 
        if ( val.num_writers > 0 ) { 
          go_BYE(-1);
        }
      }
      if ( val.num_writers > 0 ) { 
        if ( val.num_readers > 0 ) { 
          go_BYE(-1);
        }
      }
      if ( val.num_writers > 1 ) { go_BYE(-1); }
      //------------------
      if ( val.X != NULL ) { if ( val.nX == 0 ) { go_BYE(-1); } }
      if ( val.X == NULL ) { if ( val.nX != 0 ) { go_BYE(-1); } }
    }
    else {
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) != 0 ) {
        go_BYE(-1);
      }
      if ( memcmp(&zero_key, &(bkts[i].key), keysz) != 0 ) {
        go_BYE(-1);
      }
    }
  }
  //---------------------------------

BYE:
  return status;
}
