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
    uint32_t uqid
    )
{
  int status = 0;
  char *lma_file = NULL;
  char *X = NULL, *bak_X = NULL; size_t nX = 0, bak_nX = 0;
  char *l2_file = NULL;

  if ( tbsp != 0 ) { go_BYE(-1); } 
  if ( uqid == 0 ) { go_BYE(-1); } 
  bool vctr_is_found; uint32_t vctr_where_found;
  status = vctr_is(tbsp, uqid, &vctr_is_found, &vctr_where_found); 
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t *v = &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val);
  //-----------------------------------------------
  if ( v->is_lma ) { goto BYE; } // Nothing to do 
  if ( v->is_eov == false ) { go_BYE(-1); }
  if ( v->memo_len >= 0 ) { go_BYE(-1); }
  if ( v->num_elements == 0 ) { go_BYE(-1); }
  if ( v->width == 0 ) { go_BYE(-1); }
  // I don't think this is needed: if ( v->is_killable ) { go_BYE(-1); }
  // Control comes here => is_lma == false => 
  // num_readers, num_witers, X, nX are all NULL 
  if ( v->num_readers != 0 ) { go_BYE(-1); }
  if ( v->num_writers != 0 ) { go_BYE(-1); }
  if ( v->X != NULL ) { go_BYE(-1); }
  if ( v->nX != 0 ) { go_BYE(-1); }
  //-----------------------------------------------
  // START: Create new empty backup file 
  lma_file = l2_file_name(0, uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( file_exists(lma_file) ) { 
    fprintf(stderr ,"SUSPICIOUS but not necessarily error. ");
    fprintf(stderr, "LMA File [%s] exists for vector (%u,%s)\n",
        lma_file, uqid, v->name);
    // go_BYE(-1); 
  } 

  uint64_t filesz = v->num_elements * v->width;
  if ( filesz == 0 ) { go_BYE(-1); }
  // Check if space exists for file about to be created 
  uint64_t dsk_used = get_dsk_used(); 
  uint64_t dsk_allowed = get_dsk_allowed(); 
  if ( dsk_allowed < dsk_used ) { go_BYE(-1); }
  if ( dsk_allowed - dsk_used < filesz ) { go_BYE(-1); }
  status = incr_dsk_used(filesz); cBYE(status);
  //----------------------------------------------------
  status = mk_file(NULL, lma_file, filesz); cBYE(status);
  status = rs_mmap(lma_file, &X, &nX, 1); cBYE(status); 
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  bak_X = X; bak_nX = nX; // X, nX modified below, hence bak_X
  // STOP : Create empty backup file 
  uint32_t max_chnk_idx = v->max_chnk_idx; 
  for ( uint32_t chnk_idx = 0; chnk_idx <= max_chnk_idx; chnk_idx++ ) { 
    bool b_chnk_is; uint32_t chnk_where;
    status = chnk_is(tbsp, uqid, chnk_idx, &b_chnk_is, &chnk_where);
    cBYE(status);
    if ( !b_chnk_is ) { go_BYE(-1); }
    chnk_rs_hmap_val_t *ptr_chnk = 
      &(g_chnk_hmap[tbsp].bkts[chnk_where].val);
    //-------------------------------
    uint32_t num_in_chnk = ptr_chnk->num_elements;
    if ( num_in_chnk == 0 ) { go_BYE(-1); }
    // Not needed: if ( ptr_chnk->num_readers != 0 ) { go_BYE(-1); } 
    if ( ptr_chnk->num_writers != 0 ) { go_BYE(-1); } 
    // Get access to the data to copy 
    char *data = NULL; size_t bytes_to_copy; 
    char *Y = NULL; size_t nY = 0;
    if ( ptr_chnk->l1_mem != NULL ) { 
      uint32_t pre = ptr_chnk->num_readers;
      data  = chnk_get_data(tbsp, chnk_where, false);
      uint32_t post = ptr_chnk->num_readers;
      if ( (pre+1) != post ) { go_BYE(-1); } 
      ptr_chnk->num_readers--;
    }
    else {
      // IMPORTANT: Bypass direct chnk_get_data call 
      // This is because we don't want to force a load into l1 mem 
      // Note that whatI am doing is somewhat dangerous since I am 
      // bypassing my own APIs like chnk_get_data(). The reason is 
      // efficiency. Time will tell if this was a smart move
      if ( !ptr_chnk->l2_exists ) { go_BYE(-1); } 
      l2_file = l2_file_name(tbsp, uqid, chnk_idx);
      if ( l2_file == NULL ) { go_BYE(-1); }
      status = rs_mmap(l2_file, &Y, &nY, 0); cBYE(status);
      data = Y;
    }
    bytes_to_copy = num_in_chnk * v->width;
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
  // update meta data 
  v->is_lma = true;
BYE:
  mcr_rs_munmap(bak_X, bak_nX); // X, nX are modified in the loop
  free_if_non_null(lma_file);
  free_if_non_null(l2_file);
  return status;
}
