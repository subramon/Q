#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "vctr_is.h"
#include "chnk_del.h"
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

  status = vctr_is(tbsp, uqid, ptr_is_found, &where_found); cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  bool is_persist = val.is_persist;
  bool is_lma     = val.is_lma;
  // Following is okay but happens rarely. Happens when you create a
  // vector but do not eval() it or get_chunk() it 
  // if ( val.ref_count == 0 ) { go_BYE(-1); }
  g_vctr_hmap[tbsp].bkts[where_found].val.ref_count--;
  if ( g_vctr_hmap[tbsp].bkts[where_found].val.ref_count > 0 ) {
    goto BYE;
  }
  val = g_vctr_hmap[tbsp].bkts[where_found].val;
  //if ( val.name[0] != '\0' ) { printf("Deleting Vctr: %s \n", val.name); }
  // delete lma file if it exists
  if ( ( is_lma ) && ( !is_persist ) ) {
    if ( val.num_readers != 0 ) { go_BYE(-1); }
    if ( val.num_writers != 0 ) { go_BYE(-1); }
    lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
    if ( lma_file == NULL ) { go_BYE(-1); }
    // delete file only if in your own tablespace
    if ( ( file_exists(lma_file) ) && ( tbsp == 0 ) ) { 
      unlink(lma_file); 
    }
    char *X = g_vctr_hmap[tbsp].bkts[where_found].val.X;
    size_t nX = g_vctr_hmap[tbsp].bkts[where_found].val.nX;
    if ( ( X != NULL ) && ( nX != 0 ) ) { munmap(X, nX); }
    g_vctr_hmap[tbsp].bkts[where_found].val.is_lma = false;
  }
  //-------------------------------------------
  // Delete chunks in vector before deleting vector 
  if ( val.num_elements > 0 )  {
    if ( val.is_lma == false ) { if ( val.num_chnks == 0 ) { go_BYE(-1); } }
    for ( uint32_t chnk_idx = 0; chnk_idx <= val.max_chnk_idx; chnk_idx++ ){
    if ( val.num_chnks == 0 ) { break; } 
      uint32_t old_nitems = g_chnk_hmap[tbsp].nitems;
      if ( old_nitems == 0 ) { go_BYE(-1); }
      bool is_found = true;
      status = chnk_del(tbsp, uqid, chnk_idx, is_persist); 
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
      uint32_t new_nitems = g_chnk_hmap[tbsp].nitems;
      if ( is_found ) { 
        if ( new_nitems != (old_nitems-1) ) { go_BYE(-1); }
      }
    }
  }
  bool is_found;
  vctr_rs_hmap_key_t key = uqid; 
  status = g_vctr_hmap[0].del(&g_vctr_hmap[tbsp], &key, &val, &is_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
BYE:
  if ( status < 0 ) { 
    printf("Error in deleting Vector %s \n", val.name);
  }
  free_if_non_null(lma_file);
  return status;
}
