#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "chnk_is.h"
#include "file_exists.h"
#include "mk_file.h"
#include "rs_mmap.h"
#include "chnk_get_data.h"
#include "get_file_size.h"
#include "l2_file_name.h"
#include "mod_mem_used.h"
#include "vctr_add.h"
#include "vctr_chnks_to_lma.h"


extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_chnks_to_lma(
    uint32_t tbsp,
    uint32_t old_uqid,
    uint32_t *ptr_new_uqid
    )
{
  int status = 0;
  char *lma_file = NULL;
  char *X = NULL, *bak_X = NULL; size_t nX = 0, bak_nX = 0;
  char *l2_file = NULL;

  *ptr_new_uqid = 0;
  if ( tbsp != 0 ) { go_BYE(-1); } 
  if ( old_uqid == 0 ) { go_BYE(-1); } 
  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, old_uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t v = g_vctr_hmap[tbsp].bkts[vctr_where_found].val;
  //-----------------------------------------------
#ifdef DEBUG
  if ( v.is_eov == false ) { go_BYE(-1); }
  if ( v.num_elements == 0 ) { go_BYE(-1); }
  if ( v.width == 0 ) { go_BYE(-1); }
  if ( v.is_lma ) { go_BYE(-1); }
  if ( v.is_killable ) { go_BYE(-1); }
  if ( v.num_readers != 0 ) { go_BYE(-1); }
  if ( v.num_writers != 0 ) { go_BYE(-1); }
  if ( v.X != NULL ) { go_BYE(-1); }
  if ( v.nX != 0 ) { go_BYE(-1); }

  lma_file = l2_file_name(tbsp, old_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( file_exists(lma_file) ) { go_BYE(-1); } 
  free_if_non_null(lma_file);
#endif
  //-----------------------------------------------


  // Create output vector 
  uint32_t new_uqid = 0; 
  status = vctr_add1(v.qtype, v.width, v.max_num_in_chnk, -1, 
      v.is_killable, &new_uqid);
  cBYE(status);
  // START check that output vector got created
  uint32_t new_where;
  status = vctr_is(0, new_uqid, &vctr_is_found, &new_where); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
#ifdef DEBUG
  if ( g_vctr_hmap[0].bkts[new_where].val.qtype != v.qtype ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.width != v.width ) { go_BYE(-1); } 
  if ( g_vctr_hmap[0].bkts[new_where].val.max_num_in_chnk != v.max_num_in_chnk ) { go_BYE(-1); } 
#endif
  // STOP  check that output vector got created

  // START: Create new empty backup file 
  lma_file = l2_file_name(0, new_uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( file_exists(lma_file) ) { go_BYE(-1); } 

  uint64_t filesz = v.num_elements * v.width;
  if ( filesz == 0 ) { go_BYE(-1); }
  uint64_t dsk_used = get_dsk_used(); 
  uint64_t dsk_allowed = get_dsk_allowed(); 
  if ( dsk_allowed < dsk_used ) { go_BYE(-1); }
  if ( dsk_allowed - dsk_used < filesz ) { go_BYE(-1); }
  status = incr_dsk_used(filesz); cBYE(status);
  status = mk_file(NULL, lma_file, filesz); cBYE(status);
  status = rs_mmap(lma_file, &X, &nX, 1); cBYE(status); 
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  bak_X = X; bak_nX = nX;
  // STOP : Create empty backup file 
  uint32_t max_chnk_idx = v.max_chnk_idx; 
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) { 
    bool chnk_is_found; uint32_t chnk_where_found;
    status = chnk_is(tbsp, old_uqid, chnk_idx, &chnk_is_found,
        &chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    chnk_rs_hmap_val_t *ptr_val = 
      &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);
    //-------------------------------
    uint32_t num_in_chnk = ptr_val->num_elements;
    uint32_t num_readers = ptr_val->num_readers;
    uint32_t num_writers = ptr_val->num_writers;
    if ( num_readers != 0 ) { go_BYE(-1); } 
    if ( num_writers != 0 ) { go_BYE(-1); } 
    // IMPORTANT: Bypass direct chnk_get_data call 
    // This is because we don't want to force a load into l1 mem 
    // Note that whatI am doing is somewhat dangerous since I am 
    // bypassing my own APIs like chnk_get_data(). The reason is 
    // efficiency. Time will tell if this was a smart move
    char *data = NULL; size_t bytes_to_copy; 
    char *Y = NULL; size_t nY = 0;
    if ( ptr_val->l1_mem != NULL ) { 
      data  = chnk_get_data(tbsp, chnk_where_found, false);
      num_readers = ptr_val->num_readers;
      if ( num_readers != 1 ) { go_BYE(-1); } 
      g_chnk_hmap[tbsp].bkts[chnk_where_found].val.num_readers = 0;
    }
    else {
      if ( !ptr_val->l2_exists ) { go_BYE(-1); } 
      l2_file = l2_file_name(tbsp, old_uqid, chnk_idx);
      if ( l2_file == NULL ) { go_BYE(-1); }
      status = rs_mmap(l2_file, &Y, &nY, 0); cBYE(status);
      data = Y;
    }
    bytes_to_copy = num_in_chnk * v.width;
    free_if_non_null(l2_file);
    if ( bytes_to_copy > nX ) { go_BYE(-1); } 
    if ( data == NULL ) { go_BYE(-1); } 
    //------------------------------------------------------------
    memcpy(X, data, bytes_to_copy); 
    X  += bytes_to_copy;
    nX -= bytes_to_copy;
    //--- release data if needed 
    if ( Y != NULL ) { munmap(Y, nY); }

  }
  // update meta data for new vector
  g_vctr_hmap[0].bkts[new_where].val.is_eov = true;
  g_vctr_hmap[0].bkts[new_where].val.is_lma = true;
  g_vctr_hmap[0].bkts[new_where].val.num_elements = v.num_elements;
  g_vctr_hmap[0].bkts[new_where].val.memo_len = -1;
  *ptr_new_uqid = new_uqid;
BYE:
  mcr_rs_munmap(bak_X, bak_nX); // X, nX are modified in the loop
  free_if_non_null(lma_file);
  free_if_non_null(l2_file);
  return status;
}
