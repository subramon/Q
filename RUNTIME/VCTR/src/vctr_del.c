#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_del.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "get_file_size.h"
#include "mod_mem_used.h"
#include "vctr_is.h"
#include "chnk_is.h"
#include "chnk_del.h"
#include "vctr_usage.h"
#include "vctr_del.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

int
vctr_del(
    uint32_t tbsp, // table space 
    uint32_t uqid,
    bool *ptr_is_found
    )
{
  int status = 0;
  uint32_t where_found = ~0;
  char *lma_file = NULL;
  char *val_name = NULL;
  vctr_rs_hmap_key_t nn_key; memset(&nn_key, 0, sizeof(nn_key));

  status = vctr_is(tbsp, uqid, ptr_is_found, &where_found); cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t vctr_val = g_vctr_hmap[tbsp].bkts[where_found].val;
  vctr_rs_hmap_val_t *ptr_vctr_val = 
    &(g_vctr_hmap[tbsp].bkts[where_found].val);
  if ( vctr_val.name[0] != '\0' ) { 
    val_name = strdup(vctr_val.name);
  }
  else {
    val_name = strdup("anonymous");
  }
  bool is_persist = vctr_val.is_persist;
  bool is_lma     = vctr_val.is_lma;
  bool has_nn     = vctr_val.has_nn;
  if ( has_nn ) { 
    uint32_t nn_uqid = vctr_val.nn_key; 
    if ( nn_uqid == 0 ) { go_BYE(-1); }
    // break connection from primary to nn
    ptr_vctr_val->has_nn = false; 
    ptr_vctr_val->nn_key = 0; 
    // break connection from nn to parent 
    bool nn_is_found; uint32_t nn_where_found;
    status = vctr_is(tbsp, nn_uqid, &nn_is_found, &nn_where_found); 
    cBYE(status);
    if ( !nn_is_found ) { goto BYE; }
    vctr_rs_hmap_val_t *ptr_nn_vctr_val = 
      &(g_vctr_hmap[tbsp].bkts[nn_where_found].val);
    if ( !ptr_nn_vctr_val->has_parent ) { go_BYE(-1); } 
    ptr_nn_vctr_val->has_parent = false; 
    if ( ptr_nn_vctr_val->parent_key == 0 ) { go_BYE(-1); }
    ptr_nn_vctr_val->parent_key = 0;
  }
#ifdef VERBOSE
  if ( vctr_val.name[0] != '\0' ) { printf("Deleting Vctr: %s \n", vctr_val.name); }
#endif
  // delete lma file if it exists
  if ( ( is_lma ) && ( !is_persist ) ) {
    if ( vctr_val.num_readers != 0 ) { go_BYE(-1); }
    if ( vctr_val.num_writers != 0 ) { go_BYE(-1); }
    lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    // delete file only if in your own tablespace
    if ( ( file_exists(lma_file) ) && ( tbsp == 0 ) ) { 
      int64_t filesz = get_file_size(lma_file); 
      if ( filesz < 0 ) { go_BYE(-1); } 
      unlink(lma_file); 
      status = decr_dsk_used(filesz); 
    }
    char *X = g_vctr_hmap[tbsp].bkts[where_found].val.X;
    size_t nX = g_vctr_hmap[tbsp].bkts[where_found].val.nX;
    if ( ( X != NULL ) && ( nX != 0 ) ) { munmap(X, nX); }
    g_vctr_hmap[tbsp].bkts[where_found].val.is_lma = false;
  }
  if ( ( is_lma ) && ( is_persist ) ) {
    // printf("Not deleting file baclup for Vctr: %s \n", vctr_val.name); 
  }
  //-------------------------------------------
  if ( vctr_val.num_elements == 0 ) {
    // This can happen when we call get_chunk on a vector but
    // never call put_chunk. Typically for intermediate vectors
    // Makes me wonder how this interplays with memo_len
    // TODO P2 Think about this.
    bool vctr_is_found;
    vctr_rs_hmap_key_t vctr_key = uqid; 
    status = vctr_rs_hmap_del(&(g_vctr_hmap[tbsp]), &vctr_key, &vctr_val, 
        &vctr_is_found); 
    cBYE(status);
    if ( !vctr_is_found ) { go_BYE(-1); }
    goto BYE;
  }
  // Delete chunks in vector before deleting vector 
  for ( uint32_t chnk_idx = vctr_val.min_chnk_idx; 
      chnk_idx <= vctr_val.max_chnk_idx; chnk_idx++ ) {
    uint32_t old_nitems = g_chnk_hmap[tbsp].nitems;
    bool chnk_is_found = true; uint32_t chnk_where_found;
    status = chnk_is(tbsp, uqid, chnk_idx, &chnk_is_found,
        &chnk_where_found);
    cBYE(status);
    // chunk must exist unless vector is in error state 
    if ( !vctr_val.is_error ) { 
      if ( !chnk_is_found ) { go_BYE(-1); } 
    }
    status = chnk_del(tbsp, uqid, chnk_idx, is_persist); 
    cBYE(status);
    uint32_t new_nitems = g_chnk_hmap[tbsp].nitems;
    if ( new_nitems != (old_nitems-1) ) { go_BYE(-1); }
  }
  bool is_found;
  vctr_rs_hmap_key_t vctr_key = uqid; 
  status = vctr_rs_hmap_del(&(g_vctr_hmap[tbsp]), &vctr_key, &vctr_val, 
      &is_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  uint64_t mem_used, dsk_used;
  status = vctr_usage(tbsp, uqid, &mem_used, &dsk_used); cBYE(status);
  if ( mem_used != 0 ) { go_BYE(-1); } 
  if ( dsk_used != 0 ) { go_BYE(-1); } 
  // Delete nn vector if one exists
  if ( has_nn ) { 
    status = vctr_del(tbsp, nn_key, &is_found); cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
  }
BYE:
  if ( status < 0 ) { 
    printf("Error in deleting Vector %s \n", vctr_val.name);
  }
  free_if_non_null(lma_file);
  free_if_non_null(val_name);
  return status;
}
