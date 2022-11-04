#include "q_incs.h"
#include "q_macros.h"
#include "rmtree.h"

#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "isfile.h"
#include "get_file_size.h"
#include "l2_file_name.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "qtypes.h"
#include "vctr_chk.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;


int
vctrs_chk(
    bool is_at_rest
    )
{
  int status = 0;
  // Above check needed because (unfortunately) I have used
  // uint32_t everywhere instead of vctr_rs_hmap_key_t 
  if ( sizeof(uint32_t) != sizeof(vctr_rs_hmap_key_t)) { go_BYE(-1); }
  uint32_t total_num_chunks = 0;
  for ( uint32_t i = 0; i < g_vctr_hmap.size; i++ ) { 
    vctr_rs_hmap_val_t vctr_val;
    memset(&vctr_val, 0, sizeof(vctr_rs_hmap_val_t));
    vctr_rs_hmap_key_t vctr_key;
    memset(&vctr_key, 0, sizeof(vctr_rs_hmap_key_t));
    if ( g_vctr_hmap.bkt_full[i] == false ) {
      // key and value must be empty 
      if ( memcmp(&g_vctr_hmap.bkts[i].val, &vctr_val, 
            sizeof(vctr_rs_hmap_val_t)) != 0 ) {
        go_BYE(-1); 
      }
      if ( memcmp(&g_vctr_hmap.bkts[i].key, &vctr_key, 
            sizeof(vctr_rs_hmap_key_t)) != 0 ) {
        go_BYE(-1); 
      }
      continue; 
    }
    status = vctr_chk(g_vctr_hmap.bkts[i].key, is_at_rest); cBYE(status); 
    total_num_chunks += g_vctr_hmap.bkts[i].val.num_chnks;
  }
  if ( total_num_chunks != g_chnk_hmap.nitems ) { 
    go_BYE(-1); 
  }
BYE:
  return status;
}
int
vctr_chk(
    uint32_t vctr_uqid,
    bool is_at_rest
    )
{
  int status = 0;

  // early exit case
  if ( vctr_uqid == 0 ) { goto BYE; }

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  vctr_rs_hmap_val_t vctr_val = g_vctr_hmap.bkts[vctr_where_found].val;
  uint32_t qtype           = vctr_val.qtype;
  if ( qtype >= NUM_QTYPES ) { go_BYE(-1); } 
  if ( qtype <= Q0 ) { go_BYE(-1); } 
  uint32_t width           = vctr_val.width;
  // Unfortunately, we have some special casing to do here
  if ( qtype == B1 ) { 
    if  ( width != 0 ) { go_BYE(-1); }
  }
  else if ( qtype == SC ) {
    if  ( width < 2 ) { go_BYE(-1); }
  }
  else { 
    if ( get_width_c_qtype(qtype) != (int)width ) { go_BYE(-1); }
  }
  //-----------------------------------------
  uint64_t num_elements    = vctr_val.num_elements;
  uint32_t num_chnks       = vctr_val.num_chnks;
  uint32_t max_chnk_idx    = vctr_val.max_chnk_idx;
  uint32_t max_num_in_chnk = vctr_val.max_num_in_chnk;
  bool is_early_free       = vctr_val.is_early_free;
  bool chk_is_early_free = false;

  if ( vctr_val.is_lma == false ) { 
    if ( vctr_val.X != NULL ) { go_BYE(-1); }
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
    if ( ( vctr_val.num_readers != 0 ) || ( vctr_val.num_writers != 0 ) ) { 
      go_BYE(-1);
    }
  }
  //----------------------------------------------
  if ( ( vctr_val.num_readers == 0 ) && ( vctr_val.num_writers == 0 ) ) { 
    if ( vctr_val.X != NULL ) { go_BYE(-1); }
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
  }
  //---------------------------
  if ( vctr_val.num_readers > 0 ) {
    if ( vctr_val.num_writers != 0 ) { go_BYE(-1); }
    if ( vctr_val.X == NULL ) { go_BYE(-1); }
    if ( vctr_val.nX == 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.num_writers > 0 ) {
    if ( vctr_val.num_readers != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_writers != 1 ) { go_BYE(-1); }
    if ( vctr_val.X != NULL ) { go_BYE(-1); }
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------

  if ( vctr_val.is_lma ) { 
    if ( !vctr_val.is_eov ) { go_BYE(-1); }
    uint32_t good_filesz = num_elements * width;
    char *l2_file = l2_file_name(vctr_uqid, ((uint32_t)~0)); 
    if ( !isfile(l2_file) ) { go_BYE(-1); }
    int64_t filesz = get_file_size(l2_file);
    if ( filesz != good_filesz ) { go_BYE(-1); }
    free_if_non_null(l2_file);
  }
  else {
    if ( num_elements > 0 ) {
      if ( num_chnks == 0 ) { go_BYE(-1);
      }
    }
  }
  uint64_t chk_num_elements    = 0;
  // we can have an empty Vector (while it is being created)
  if ( vctr_val.is_eov ) {  
    if ( vctr_val.ref_count == 0 ) {  go_BYE(-1); }
  }
  // if ( num_elements == 0 ) { go_BYE(-1); } 
  if (((max_num_in_chnk/8)*8) != max_num_in_chnk ) { go_BYE(-1); }
  // name must be null terminated 
  if ( vctr_val.name[MAX_LEN_VCTR_NAME] != '\0' ) { go_BYE(-1); }
  int good_filesz  = width * max_num_in_chnk;
  // early exit case
  if ( ( vctr_val.is_lma ) && ( num_chnks == 0 ) ) { goto BYE; }
  //------------
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) {
    if ( num_elements == 0 ) { break; } // NOTE: Special case for empty vec
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(vctr_uqid, chnk_idx,&chnk_is_found,&chnk_where_found);
    cBYE(status);
    // TODO P3 Tighten following test 
    if ( vctr_val.memo_len < 0 ) { 
      if ( !chnk_is_found ) { go_BYE(-1); }
    }
    if ( !chnk_is_found ) { continue; }
    //------------
    chnk_rs_hmap_val_t chnk_val;
    memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
    chnk_rs_hmap_key_t chnk_key;
    memset(&chnk_key, 0, sizeof(chnk_rs_hmap_key_t));
    chnk_val = g_chnk_hmap.bkts[chnk_where_found].val;
    chnk_key = g_chnk_hmap.bkts[chnk_where_found].key;
    if ( chnk_val.is_early_free ) { chk_is_early_free = true; } 
    if ( is_at_rest ) { 
      if ( chnk_val.num_readers != 0 ) { go_BYE(-1); } 
      if ( chnk_val.num_writers != 0 ) { go_BYE(-1); } 
    }
    if ( chnk_val.num_readers > 0 ) { 
      if ( chnk_val.num_writers != 0 ) { go_BYE(-1); } 
    }
    if ( chnk_val.num_writers > 0 ) { 
      if ( chnk_val.num_readers != 0 ) { go_BYE(-1); } 
    }
    if ( ( chnk_val.num_elements == 0 ) || 
        ( chnk_val.num_elements > max_num_in_chnk ) ) { 
      go_BYE(-1);
    }
    // all but last chunk must be full 
    if ( chnk_idx < num_chnks-1 ) { // for all but last chunk
      if ( chnk_val.num_elements != max_num_in_chnk ) { go_BYE(-1); }
    }
    chk_num_elements += chnk_val.num_elements;
    if ( chnk_val.qtype != qtype ) { go_BYE(-1); }
    if ( chnk_val.is_early_free ) { 
      if ( chnk_val.l2_exists ) { go_BYE(-1); } 
      if ( chnk_val.l1_mem != NULL  ) { go_BYE(-1); } 
      char *l2_file = l2_file_name(vctr_uqid, chnk_idx);
      if ( isfile(l2_file) ) { go_BYE(-1); }
      free_if_non_null(l2_file);
    }
    else {
      // if data not in L2, must be in L1 
      if ( chnk_val.l2_exists == false ) { 
        if ( chnk_val.l1_mem == NULL ) { go_BYE(-1); }
      }
      else { // check that file exists 
        char *l2_file = l2_file_name(vctr_uqid, chnk_idx);
        if ( !isfile(l2_file) ) { go_BYE(-1); }
        int64_t filesz = get_file_size(l2_file);
        if ( filesz != good_filesz ) { go_BYE(-1); }
        free_if_non_null(l2_file);
      }
    }
  }
  if ( is_early_free ) { if ( !chk_is_early_free ) { go_BYE(-1); } }
  if ( !is_early_free ) { if ( chk_is_early_free ) { go_BYE(-1); } }
  // if no memo, then num in chunk should match num in vector 
  if ( vctr_val.memo_len < 0 ) { 
    if ( chk_num_elements != num_elements ) { go_BYE(-1); }
  }
BYE:
  return status;
}
