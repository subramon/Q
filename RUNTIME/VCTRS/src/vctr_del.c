#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "vctr_is.h"
#include "chnk_del.h"
#include "vctr_del.h"

extern vctr_rs_hmap_t g_vctr_hmap;
extern chnk_rs_hmap_t g_chnk_hmap;

int
vctr_del(
    uint32_t uqid,
    bool *ptr_is_found
    )
{
  int status = 0;
  uint32_t where_found;
  char *lma_file = NULL;

  status = vctr_is(uqid, ptr_is_found, &where_found); cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap.bkts[where_found].val;
  bool is_persist = val.is_persist;
  if ( val.ref_count == 0 ) { go_BYE(-1); }
  g_vctr_hmap.bkts[where_found].val.ref_count--;
  if ( g_vctr_hmap.bkts[where_found].val.ref_count > 0 ) {
    goto BYE;
  }
  val = g_vctr_hmap.bkts[where_found].val;
  if ( val.name[0] != '\0' ) { 
    printf("Deleting Vector: %s \n", val.name);
  }
  // delete lma file if it exists
  if ( !is_persist ) { 
    lma_file = l2_file_name(uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    if ( file_exists(lma_file) ) { 
      unlink(lma_file);
    }
  }
  //-------------------------------------------
  // Delete chunks in vector before deleting vector 
  if ( val.num_elements > 0 ) { 
    if ( val.num_chnks == 0 ) { go_BYE(-1); }
    for ( uint32_t chnk_idx = 0; chnk_idx <= val.max_chnk_idx; chnk_idx++ ){ 
      uint32_t old_nitems = g_chnk_hmap.nitems;
      if ( old_nitems == 0 ) { go_BYE(-1); }
      bool is_found = true;
      status = chnk_del(uqid, chnk_idx, is_persist); 
      if ( status == -3 ) { status = 0; is_found = false; } 
      cBYE(status);
      if ( val.memo_len < 0 ) {  
        // memo length infinite means all chunks must have been saved
        if ( !is_found ) { 
          go_BYE(-1); 
        }
      }
      else {
        // we may have deleted chunks that are too 
        uint32_t watermark = val.max_chnk_idx - val.memo_len;
        if ( chnk_idx >= watermark ) {
          if ( !is_found ) { go_BYE(-1); }
        }
        else {
          if ( is_found ) { 
            printf("Found chunk %u. Should not have existed\n", chnk_idx);
            // go_BYE(-1); 
          }
        }
      }
      uint32_t new_nitems = g_chnk_hmap.nitems;
      if ( is_found ) { 
        if ( new_nitems != (old_nitems-1) ) { go_BYE(-1); }
      }
    }
  }
  bool is_found;
  vctr_rs_hmap_key_t key = uqid; 
  status = g_vctr_hmap.del(&g_vctr_hmap, &key, &val, &is_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
BYE:
  free_if_non_null(lma_file);
  return status;
}
