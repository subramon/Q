#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_del.h"
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
// vctr_early_free() Can be called multiple times
int
vctr_early_free(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t ub_chnk_idx // => free all chunks upto but excluding this
    )
{
  int status = 0;
  bool vctr_is_found; uint32_t vctr_where;
  chnk_rs_hmap_val_t *ptr_chnk_val = NULL;
  vctr_rs_hmap_val_t *ptr_vctr_val = NULL;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where); 
  cBYE(status);
  if ( vctr_is_found == false ) { goto BYE; }
  ptr_vctr_val = &(g_vctr_hmap[tbsp].bkts[vctr_where].val);
  uint32_t min_chnk_idx = ptr_vctr_val->min_chnk_idx; 
  // conditions under which early free ignored
  if ( ptr_vctr_val->is_persist ) { goto BYE; }
  if ( ptr_vctr_val->is_eov ) { goto BYE; }
  if ( ptr_vctr_val->num_elements == 0 ) { goto BYE; }
  if ( ptr_vctr_val->is_early_freeable    == false ) { goto BYE; }
  // We do not delete most recent chunk
  for ( uint32_t chnk_idx = min_chnk_idx; chnk_idx <= ub_chnk_idx; 
      chnk_idx++ ){
    bool chnk_is_found; uint32_t chnk_where; 
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found, &chnk_where);
    if ( chnk_is_found == false ) { continue; } // IMPORTANT: not an error
    ptr_chnk_val = &(g_chnk_hmap[tbsp].bkts[chnk_where].val);
    if ( ptr_chnk_val->num_free_ignore > 0 ) { 
      ptr_chnk_val->num_free_ignore--;
      continue;
    }
    //---------------------------------------------------
    printf("Early free deleting chunk_idx %u \n", chnk_idx); 
    if ( ptr_chnk_val->num_readers != 0 ) { go_BYE(-1); } // unsure
    if ( ptr_chnk_val->num_writers != 0 ) { go_BYE(-1); } // unsure
    //---------------------------------------------------
    // memory for chunk must exist 
    if ( ( ptr_chnk_val->l1_mem == NULL ) &&
        ( ptr_chnk_val->l2_exists == false ) ) {
      printf("TODO Consider whether control should be able to come here\n");
      continue; 
    }
    // printf("Deleting chunk for early free\n");
    status = chnk_del(tbsp, vctr_uqid, chnk_idx, false); cBYE(status); 
    ptr_vctr_val->min_chnk_idx = chnk_idx + 1;
    //------------------------
  }
BYE:
  return status;
}
