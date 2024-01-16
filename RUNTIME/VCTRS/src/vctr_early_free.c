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
// vctr_early_free() Can be called multiple times
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
  // conditions under which early free ignored
  if ( ptr_vctr_val->is_persist ) { goto BYE; }
  if ( ptr_vctr_val->num_elements == 0 ) { goto BYE; }
  if ( ptr_vctr_val->num_chnks    == 0 ) { goto BYE; }
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
    if ( ptr_chnk_val->was_early_freed ) { 
      if ( ( ptr_chnk_val->l1_mem != NULL ) ||
        ( ptr_chnk_val->l2_exists == true ) ) {
        go_BYE(-1);
      }
      // Following ensures a chunk is not freed twice
      continue; 
    }
    //---------------------------------------------------
    if ( ptr_chnk_val->num_readers != 0 ) { continue; } 
    if ( ptr_chnk_val->num_writers != 0 ) { continue; } 
    if ( ptr_chnk_val->num_lives_left <= 0 ) { go_BYE(-1); }
    ptr_chnk_val->num_lives_left--;
    if ( ptr_chnk_val->num_lives_left > 0 ) { continue; }
    //---------------------------------------------------
    // memory for chunk must exist 
    if ( ( ptr_chnk_val->l1_mem == NULL ) &&
        ( ptr_chnk_val->l2_exists == false ) ) {
      printf("TODO Consider whether control should be able to come here\n");
      continue; 
    }
    // free resources for the chunk. Note that we do NOT free the chunk
    ptr_vctr_val->num_early_freed++;
    printf("Deleting chunk for early free\n");
    status = chnk_free_resources(tbsp, ptr_chnk_key, ptr_chnk_val,
        ptr_vctr_val->is_persist); 
    cBYE(status); 
    //------------------------
    ptr_chnk_val->l2_exists = false;
    ptr_chnk_val->was_early_freed = true;
    //------------------------
  }
BYE:
  return status;
}
// once a vector has been marked early_freeable, you can undo it 
// only if it has zero elements in it 
int
vctr_set_num_lives_free(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int num_lives_free
    )
{
  int status = 0;
  // nothing to do for vectors in other tablespaces
  if ( tbsp != 0 ) { goto BYE; } 
  if ( num_lives_free < 0 ) { go_BYE(-1); }
  if ( num_lives_free == 0 ) { goto BYE; }
  if ( num_lives_free >= 16 ) { go_BYE(-1); } // some reasonable limit 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { go_BYE(-1); }
  if ( val.is_persist ) { go_BYE(-1); }
  if ( val.num_elements > 0 ) { go_BYE(-1); }
  if ( val.memo_len >= 0 ) { go_BYE(-1); }
  // I don't think this is needed: if ( val.is_eov ) { go_BYE(-1); } 

  g_vctr_hmap[tbsp].bkts[where_found].val.is_early_freeable = true; 
  g_vctr_hmap[tbsp].bkts[where_found].val.num_lives_free = num_lives_free; 
BYE:
  return status;
}
int 
vctr_get_num_lives_free(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    bool *ptr_is_early_freeable,
    int *ptr_num_lives_free,
    int *ptr_num_early_freed
    )
{
  int status = 0;
  if ( tbsp != 0 ) { goto BYE; } 
  bool is_found; uint32_t where_found = ~0;
  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = g_vctr_hmap[tbsp].get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { goto BYE; } 
  *ptr_is_early_freeable = val.is_early_freeable;
  *ptr_num_lives_free = val.num_lives_free;
  *ptr_num_early_freed = val.num_early_freed;
BYE:
  return status;
}
