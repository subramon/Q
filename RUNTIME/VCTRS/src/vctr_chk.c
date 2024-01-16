#include "q_incs.h"
#include "q_macros.h"
#include "qjit_consts.h"
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


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctrs_chk(
    uint32_t tbsp
    )
{
  int status = 0;
  // relax above restriction TODO P4 
  // Above check needed because (unfortunately) I have used
  // uint32_t everywhere instead of vctr_rs_hmap_key_t 
  if ( sizeof(uint32_t) != sizeof(vctr_rs_hmap_key_t)) { go_BYE(-1); }
  uint32_t total_num_chunks = 0;
  for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) { 
    vctr_rs_hmap_val_t vctr_val;
    memset(&vctr_val, 0, sizeof(vctr_rs_hmap_val_t));
    vctr_rs_hmap_key_t vctr_key;
    memset(&vctr_key, 0, sizeof(vctr_rs_hmap_key_t));
    if ( g_vctr_hmap[tbsp].bkt_full[i] == false ) {
      // key and value must be empty 
      if ( memcmp(&g_vctr_hmap[tbsp].bkts[i].val, &vctr_val, 
            sizeof(vctr_rs_hmap_val_t)) != 0 ) {
        go_BYE(-1); 
      }
      if ( memcmp(&g_vctr_hmap[tbsp].bkts[i].key, &vctr_key, 
            sizeof(vctr_rs_hmap_key_t)) != 0 ) {
        go_BYE(-1); 
      }
      continue; 
    }
    status = vctr_chk(tbsp, g_vctr_hmap[tbsp].bkts[i].key);
    cBYE(status); 
    total_num_chunks += g_vctr_hmap[tbsp].bkts[i].val.num_chnks;
  }
  if ( total_num_chunks != g_chnk_hmap[tbsp].nitems ) { 
    go_BYE(-1); 
  }
BYE:
  return status;
}
int
vctr_chk(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;

  // early exit case
  if ( vctr_uqid == 0 ) { goto BYE; }

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { 
    fprintf(stderr, "Could not find vector [%u:%u]\n", 
        tbsp, vctr_uqid); go_BYE(-1); }

  vctr_rs_hmap_val_t vctr_val = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
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

  //----------------------------------------------
  if ( vctr_val.num_lives_kill < 0 ) { go_BYE(-1); } 
  if ( vctr_val.num_lives_free < 0 ) { go_BYE(-1); } 
  //----------------------------------------------
  if ( vctr_val.is_persist ) { 
    if ( vctr_val.is_early_freeable ) { go_BYE(-1); }
    if ( vctr_val.is_killable ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.num_lives_free > 0 ) { 
    if ( vctr_val.is_persist ) { go_BYE(-1); } 
    if ( vctr_val.is_early_freeable == false ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.num_lives_kill > 0 ) { 
    if ( vctr_val.is_persist ) { go_BYE(-1); } 
    if ( vctr_val.is_killable == false ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.is_early_freeable == false ) { 
    if ( vctr_val.num_lives_free > 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.is_killable == false ) { 
    if ( vctr_val.num_lives_kill > 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.is_lma == false ) { 
    if ( vctr_val.X != NULL ) { go_BYE(-1); }
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_readers != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_writers != 0 ) { go_BYE(-1); }
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
    if ( vctr_val.X == NULL ) { go_BYE(-1); }
    if ( vctr_val.nX == 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.X == NULL ) { 
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_readers != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_writers != 0 ) { go_BYE(-1); }
  }
  if ( vctr_val.X != NULL ) { 
    if ( vctr_val.nX == 0 ) { go_BYE(-1); }
  }
  // lma access only for vectors that are fully created i.e., is_eov==true
  if ( vctr_val.X != NULL ) { 
    if ( !vctr_val.is_eov  ) { go_BYE(-1); } 
  }
  //----------------------------------------------

  if ( vctr_val.is_lma ) { 
    if ( !vctr_val.is_eov ) { go_BYE(-1); }
    uint32_t good_filesz = num_elements * width;
    char *lma_file = l2_file_name(tbsp, vctr_uqid, ((uint32_t)~0)); 
    if ( !isfile(lma_file) ) { 
      fprintf(stderr, "File not found %s \n", lma_file); go_BYE(-1); 
    }
    int64_t filesz = get_file_size(lma_file);
    if ( filesz != good_filesz ) { go_BYE(-1); }
    free_if_non_null(lma_file);
  }
  else {
    if ( num_elements > 0 ) {
      if ( num_chnks == 0 ) { go_BYE(-1);
      }
    }
  }
  // chk_num_elements computes num_elements from chunk info
  uint64_t chk_num_elements    = 0; 
  // we can have an empty Vector (while it is being created)
  if ( vctr_val.is_eov ) {  
    // if ( vctr_val.ref_count == 0 ) {  go_BYE(-1); }
    printf("TODO P1 Think about ref_count == 0\n"); 
  }
  // if ( num_elements == 0 ) { go_BYE(-1); } 
  // max_num_in_chnk must be multipke of 64 
  if (((max_num_in_chnk/64)*64) != max_num_in_chnk ) { go_BYE(-1); }
  // name must be null terminated 
  if ( vctr_val.name[MAX_LEN_VCTR_NAME] != '\0' ) { go_BYE(-1); }
  int good_filesz  = width * max_num_in_chnk;
  // early exit case
  if ( ( vctr_val.is_lma ) && ( num_chnks == 0 ) ) { goto BYE; }
  //------------
  int max_early_free_idx = -1; 
  uint32_t num_early_freed = 0;
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) {
    if ( num_elements == 0 ) { break; } // NOTE: Special case for empty vec
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(tbsp, vctr_uqid, chnk_idx,
        &chnk_is_found, &chnk_where_found);
    cBYE(status);
    // If no memo-ization, all chunks must exist
    if ( vctr_val.memo_len < 0 ) { 
      if ( !chnk_is_found ) { go_BYE(-1); }
    }
    // If memo-ization, chunks deemed "too old" must NOT exist
    if ( vctr_val.memo_len >= 0 ) { 
      if ( ( (int)max_chnk_idx - (int)chnk_idx ) > vctr_val.memo_len ) {
        // too old => chunk must not exist
        if ( chnk_is_found ) { 
          go_BYE(-1); 
        }
        else {
          continue; // nothing more to do for this dead chunk
        }
      }
    }
    
    //------------
    chnk_rs_hmap_val_t chnk_val;
    memset(&chnk_val, 0, sizeof(chnk_rs_hmap_val_t));
    chnk_rs_hmap_key_t chnk_key;
    memset(&chnk_key, 0, sizeof(chnk_rs_hmap_key_t));
    chnk_val = g_chnk_hmap[tbsp].bkts[chnk_where_found].val;
    chnk_key = g_chnk_hmap[tbsp].bkts[chnk_where_found].key;
    if ( chnk_val.was_early_freed ) { 
      max_early_free_idx = chnk_idx;
      num_early_freed++;
    }
    if ( chnk_val.num_readers != 0 ) { go_BYE(-1); } 
    if ( chnk_val.num_writers != 0 ) { go_BYE(-1); } 
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
    if ( chnk_val.was_early_freed ) { 
      if ( chnk_val.l2_exists ) { go_BYE(-1); } 
      if ( chnk_val.l1_mem != NULL  ) { go_BYE(-1); } 
      char *l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
      if ( isfile(l2_file) ) { go_BYE(-1); }
      free_if_non_null(l2_file);
    }
    else {
      // if data not in L2, must be in L1 
      if ( chnk_val.l2_exists == false ) { 
        if ( chnk_val.l1_mem == NULL ) { 
          if ( !vctr_val.is_lma ) { 
            go_BYE(-1); 
          }
        }
      }
      else { // check that file exists 
        char *l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
        if ( !isfile(l2_file) ) { 
          if ( !vctr_val.is_lma ) { 
            go_BYE(-1); 
          }
        }
        int64_t filesz = get_file_size(l2_file);
        if ( filesz != good_filesz ) { go_BYE(-1); }
        free_if_non_null(l2_file);
      }
    }
  }
  if ( vctr_val.is_early_freeable ) { 
    if ( vctr_val.num_early_freed != max_early_free_idx+1 ) { go_BYE(-1); }
    if ( vctr_val.num_chnks       < num_early_freed   +1 ) { go_BYE(-1); }
  }

  // if chunk i was early freed => chunks 0..i-1 should have been feed
  for ( int chnk_idx = 0; chnk_idx <= max_early_free_idx; chnk_idx++ ){
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(tbsp, vctr_uqid, (uint32_t)chnk_idx,
        &chnk_is_found, &chnk_where_found);
    cBYE(status);
    chnk_rs_hmap_val_t *ptr_chnk = 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);
    if ( ptr_chnk->was_early_freed == false ) { go_BYE(-1); }
  }
BYE:
  return status;
}
