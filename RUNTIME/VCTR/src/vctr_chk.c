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

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

static int
sortcompare(
    const void *in1,
    const void *in2
    )
{
  const vctr_rs_hmap_key_t  *u1 = (const vctr_rs_hmap_key_t *)in1;
  const vctr_rs_hmap_key_t  *u2 = (const vctr_rs_hmap_key_t *)in2;
  if ( *u1 < *u2 ) { 
    return -1;
  }
  else {
    return 1;
  }
}

// This function deals with checks made across vectors as oppposed
// to vctr_chk() which focuses on a single vector 
int
vctrs_chk(
    uint32_t tbsp
    )
{
  int status = 0;
  vctr_rs_hmap_key_t *parent_keys = NULL; 
  vctr_rs_hmap_key_t *nn_keys = NULL; 
  // Following check needed because (unfortunately) I have used
  // uint32_t everywhere instead of vctr_rs_hmap_key_t 
  if ( sizeof(uint32_t) != sizeof(vctr_rs_hmap_key_t)) { go_BYE(-1); }
  //--- Check that number of entries in chnk hmap matches with 
  //--  what is expected by vctr hmap 
  uint32_t total_num_chnks = 0;
  for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) {
    vctr_rs_hmap_val_t zero_vctr_val;
    memset(&zero_vctr_val, 0, sizeof(vctr_rs_hmap_val_t));
    vctr_rs_hmap_key_t zero_vctr_key;
    memset(&zero_vctr_key, 0, sizeof(vctr_rs_hmap_key_t));
    if ( g_vctr_hmap[tbsp].bkt_full[i] == false ) {
      // key and value must be empty 
      if ( memcmp(&g_vctr_hmap[tbsp].bkts[i].val, &zero_vctr_val, 
            sizeof(vctr_rs_hmap_val_t)) != 0 ) {
        go_BYE(-1); 
      }
      if ( memcmp(&g_vctr_hmap[tbsp].bkts[i].key, &zero_vctr_key, 
            sizeof(vctr_rs_hmap_key_t)) != 0 ) {
        go_BYE(-1); 
      }
      continue; 
    }
    status = vctr_chk(tbsp, g_vctr_hmap[tbsp].bkts[i].key);
    cBYE(status); 
    if ( g_vctr_hmap[tbsp].bkts[i].val.num_elements > 0 ) {
      total_num_chnks += 
        g_vctr_hmap[tbsp].bkts[i].val.max_chnk_idx - 
        g_vctr_hmap[tbsp].bkts[i].val.min_chnk_idx + 1; 
    }
  }
  if ( total_num_chnks != g_chnk_hmap[tbsp].nitems ) { 
    go_BYE(-1); 
  }
  // Return early if no items to check 
  if ( g_vctr_hmap[tbsp].nitems == 0 ) { return status; }
  // START: Checks on nulls
  // Collect all keys 
  int n = g_vctr_hmap[tbsp].nitems;
  parent_keys = malloc(n * sizeof(vctr_rs_hmap_key_t));
  nn_keys = malloc(n * sizeof(vctr_rs_hmap_key_t));
  // Remember that it is entirely okay (and most often the case) that
  // has_nn == false and has_parent == false 
  // Collect id's of nn_vecs and parent_vecs
  uint32_t num_parent_keys = 0;
  uint32_t num_nn_keys = 0;
  for ( uint32_t i = 0; i < g_vctr_hmap[tbsp].size; i++ ) {
    if ( g_vctr_hmap[tbsp].bkt_full[i] == false ) { continue; }
    vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[i].val;
    if ( val.has_parent ) { 
      parent_keys[num_parent_keys++] = g_vctr_hmap[tbsp].bkts[i].key; 
      // qtype of nn vector must be B1 or BL
      if ( ( val.qtype != B1 )  && ( val.qtype != BL ) ) { go_BYE(-1); }
    }
    if ( val.has_nn ) {
      nn_keys[num_nn_keys++] = g_vctr_hmap[tbsp].bkts[i].key; 
    }
    // Note both above conditions cannot be true 
    if ( val.has_parent && val.has_nn ) { 
      go_BYE(-1); 
    }
  }
  // parent_keys and nn_keys must match 
  if ( num_parent_keys != num_nn_keys ) { go_BYE(-1); } 
  if ( num_nn_keys > 0 ) { 
    // The same vector cannot be the nn vector for 2 different parents
    // The same vector cannot be the parent vector for 2 different nn vecs
    qsort(nn_keys, num_nn_keys, sizeof(vctr_rs_hmap_key_t), sortcompare);
    for ( uint32_t i = 1; i < num_nn_keys; i++ ) { 
      if ( nn_keys[i] == nn_keys[i-1] ) { go_BYE(-1); }
    }
    for ( uint32_t i = 1; i < num_parent_keys; i++ ) { 
      if ( parent_keys[i] == parent_keys[i-1] ) { go_BYE(-1); }
    }
  }
  // Check that nn_keys and parent_keys are valid keys 
  for ( uint32_t i = 0; i < num_parent_keys; i++ ) { 
    bool vctr_is_found; uint32_t vctr_where_found; 
    status = vctr_is(tbsp, nn_keys[i], &vctr_is_found, &vctr_where_found);
    cBYE(status);
    if ( !vctr_is_found ) { go_BYE(-1); }

    status = vctr_is(tbsp, parent_keys[i], &vctr_is_found, &vctr_where_found);
    cBYE(status);
    if ( !vctr_is_found ) { go_BYE(-1); }
  }


BYE:
  free_if_non_null(parent_keys);
  free_if_non_null(nn_keys);
  return status;
}

int
vctr_chk(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  vctr_rs_hmap_val_t vctr_val; memset(&vctr_val, 0, sizeof(vctr_val));

  // early exit case
  if ( vctr_uqid == 0 ) { goto BYE; }

  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { 
    fprintf(stderr, "Could not find vector [%u:%u]\n", 
        tbsp, vctr_uqid); go_BYE(-1); }

  vctr_val = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  uint32_t qtype           = vctr_val.qtype;
  if ( qtype >= QF ) { go_BYE(-1); } 
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
  uint32_t max_chnk_idx    = vctr_val.max_chnk_idx;
  uint32_t min_chnk_idx    = vctr_val.min_chnk_idx;
  uint32_t max_num_in_chnk = vctr_val.max_num_in_chnk;

  // cannot have an empty vector, except when under construction
  if ( num_elements == 0 ) { 
    if ( min_chnk_idx != 0 ) { go_BYE(-1); }
    if ( max_chnk_idx != 0 ) { go_BYE(-1); }
    if ( vctr_val.is_eov ) { go_BYE(-1); }
    if ( vctr_val.is_persist ) { go_BYE(-1); }
    if ( vctr_val.is_lma ) { go_BYE(-1); }
    if ( vctr_val.X != NULL ) { go_BYE(-1); }
    if ( vctr_val.nX != 0 ) { go_BYE(-1); }
    return status;
  }
    if ( min_chnk_idx > max_chnk_idx ) { go_BYE(-1); } 
    uint32_t num_chnks = max_chnk_idx - min_chnk_idx + 1;
    // last chunk can be partly empty; hence following checks 
    if ( num_elements < ( (num_chnks-1) * max_num_in_chnk ) ) { go_BYE(-1); }
    if ( vctr_val.is_memo == false ) { 
      if ( num_elements > ( num_chnks * max_num_in_chnk ) ) { 
        go_BYE(-1); 
      }
    }
  //----------------------------------------------
  if ( vctr_val.is_persist ) { 
    if ( vctr_val.is_early_freeable ) { go_BYE(-1); }
    if ( vctr_val.is_killable ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.num_free_ignore > 0 ) { 
    if ( vctr_val.is_persist ) { go_BYE(-1); } 
    if ( vctr_val.is_early_freeable == false ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.num_kill_ignore > 0 ) { 
    if ( vctr_val.is_persist ) { go_BYE(-1); } 
    if ( vctr_val.is_killable == false ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.is_early_freeable == false ) { 
    if ( vctr_val.num_free_ignore != 0 ) { go_BYE(-1); }
  }
  //----------------------------------------------
  if ( vctr_val.is_killable == false ) { 
    if ( vctr_val.num_kill_ignore != 0 ) { go_BYE(-1); }
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
    // TODO Need to undestand this 
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
    // TODO printf("TODO P1 Think about ref_count == 0\n"); 
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
  // If no memo-ization, all chunks must exist
  if ( vctr_val.is_memo == false ) { 
    if ( min_chnk_idx != 0 ) { go_BYE(-1); }
  }
  else {
    if ( num_chnks > vctr_val.memo_len ) { go_BYE(-1); }
  }
  // now, we examine each chunk of the vector 
  for ( uint32_t chnk_idx = min_chnk_idx; chnk_idx <= max_chnk_idx; 
      chnk_idx++ ) {
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(tbsp, vctr_uqid, chnk_idx,
        &chnk_is_found, &chnk_where_found);
    cBYE(status);
    //------------
    chnk_rs_hmap_val_t chnk_val = 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val;
    // early free 
    if ( vctr_val.is_early_freeable ) {
      if ( chnk_val.num_free_ignore > vctr_val.num_free_ignore ) {
        go_BYE(-1);
      }
    }
    //----------------------------------------
    if ( chnk_val.num_readers != 0 ) { 
      fprintf(stderr, "Error with chunk %u of vector %s\n",
          chnk_idx, vctr_val.name);
      fprintf(stderr, "num in chunk %u \n", chnk_val.num_elements);

      go_BYE(-1); 
    } 
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
    if ( chnk_idx < max_chnk_idx ) { // for all but last chunk
      if ( chnk_val.num_elements != max_num_in_chnk ) { go_BYE(-1); }
    }
    chk_num_elements += chnk_val.num_elements;
    if ( chnk_val.qtype != qtype ) { go_BYE(-1); }

    // if data not in L2, must be in L1  or in LMA 
    if ( chnk_val.l2_exists == false ) { 
      if ( ( chnk_val.l1_mem != NULL ) || ( vctr_val.is_lma ) ) { 
        // all well 
      }
      else {
        go_BYE(-1); 
      }
    }
    else { // check that file exists 
      char *l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
      // file must exist or vector stored in LMA 
      if ( ( isfile(l2_file) || vctr_val.is_lma ) ) { 
        // all well 
      }
      else {
        go_BYE(-1); 
      }
      int64_t filesz = get_file_size(l2_file);
      if ( filesz != good_filesz ) { go_BYE(-1); }
      free_if_non_null(l2_file);
    }
  }
BYE:
  if ( status < 0 ) { 
    printf("Error with vector [%s] \n", vctr_val.name);
  }
  return status;
}
