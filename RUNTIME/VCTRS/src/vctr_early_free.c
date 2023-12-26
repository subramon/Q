#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_free_resources.h"
#include "vctr_is.h"
#include "chnk_is.h"
#include "l2_file_name.h"
#include "isfile.h"
#include "vctr_early_free.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

// Deletes all but the most recent chunk
// Does not do anything to lma memory, assuming it exists
// Above is important difference between this call and 
// what happens when chunks age out (as determined by memo_len)
// In that case, we completely delete all resources of the chunk
// vctr_early_free()Can be called multiple times
int
vctr_early_free(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;
  bool vctr_is_found; uint32_t vctr_where;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where); 
  cBYE(status);
  if ( vctr_is_found == false ) { goto BYE; }
  vctr_rs_hmap_val_t *ptr_vctr_val = &(g_vctr_hmap[tbsp].bkts[vctr_where].val);
  // conditions under which early free not allowed
  if ( ptr_vctr_val->is_persist ) { go_BYE(-1); }
  if ( ptr_vctr_val->is_writable ) { go_BYE(-1); }
  //----------------
  // conditions under which early free ignored
  if ( ptr_vctr_val->num_elements == 0 ) { goto BYE; }
  if ( ptr_vctr_val->num_chnks    == 0 ) { goto BYE; }
  if ( ptr_vctr_val->is_early_free ) { goto BYE; } 
  // Note that we have < and not <= below. 
  // We do not delete most recent chunk
  for ( uint32_t chnk_idx = 0; 
      chnk_idx < ptr_vctr_val->max_chnk_idx; chnk_idx++ ){
    bool chnk_is_found; uint32_t chnk_where; 
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where);
    if ( chnk_is_found == false ) { go_BYE(-1); }
    chnk_rs_hmap_key_t *ptr_chnk_key = &(g_chnk_hmap[tbsp].bkts[chnk_where].key);
    chnk_rs_hmap_val_t *ptr_chnk_val = &(g_chnk_hmap[tbsp].bkts[chnk_where].val);
    // handle case where chunk has already been early freed
    if ( ptr_chnk_val->is_early_free ) { 
      if ( ptr_vctr_val->is_early_free == false ) { go_BYE(-1); }
      continue; 
    }
    // memory for chunk must exist 
    if ( ( ptr_chnk_val->l1_mem == NULL ) && 
        ( ptr_chnk_val->l2_exists == false ) ) {
      go_BYE(-1);
    }
    // free resources for the chunk. Note that we do NOT free the chunk
    status = chnk_free_resources(tbsp, ptr_chnk_key, ptr_chnk_val,
        ptr_vctr_val->is_persist); 
    cBYE(status); 
    //------------------------
    ptr_chnk_val->l2_exists = false;
    ptr_chnk_val->is_early_free = true;
    //------------------------
    // Important: If we do not delete a chunk, then we do not mark
    // the vector as early free. 
    ptr_vctr_val->is_early_free = true;
  }
BYE:
  return status;
}
