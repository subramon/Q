#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "get_file_size.h"
#include "mod_mem_used.h"
#include "vctr_is.h"
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

  status = vctr_is(tbsp, uqid, ptr_is_found, &where_found); cBYE(status);
  if ( !*ptr_is_found ) { goto BYE; }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( val.name[0] != '\0' ) { 
    val_name = strdup(val.name);
  }
  else {
    val_name = strdup("anonymous");
  }
  bool is_persist = val.is_persist;
  bool is_lma     = val.is_lma;
  // Following is okay but happens rarely. Happens when you create a
  // vector but do not eval() it or get_chunk() it 
  // if ( val.ref_count == 0 ) { go_BYE(-1); }
  if ( g_vctr_hmap[tbsp].bkts[where_found].val.ref_count > 0 ) {
    g_vctr_hmap[tbsp].bkts[where_found].val.ref_count--;
#ifdef VERBOSE
    if ( val.name[0] != '\0' ) { 
      printf("Not Deleting Vctr: %s because ref count = %u \n", 
          val.name); }
#endif
    goto BYE;
  }
#ifdef VERBOSE
  if ( val.name[0] != '\0' ) { printf("Deleting Vctr: %s \n", val.name); }
#endif
  // delete lma file if it exists
  if ( ( is_lma ) && ( !is_persist ) ) {
    if ( val.num_readers != 0 ) { go_BYE(-1); }
    if ( val.num_writers != 0 ) { go_BYE(-1); }
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
    printf("Not deleting file baclup for Vctr: %s \n", val.name); 
  }
  //-------------------------------------------
  if ( ( val.num_elements == 0 ) && ( val.num_chnks == 0 ) ) { 
    // This can happen when we call get_chunk on a vector but
    // never call put_chunk. Typically for intermediate vectors
    // Makes me wonder how this interplays with memo_len
    // TODO P2 Think about this.
    bool is_found;
    vctr_rs_hmap_key_t key = uqid; 
    status = g_vctr_hmap[0].del(&g_vctr_hmap[tbsp], &key, &val, &is_found); 
    cBYE(status);
    if ( !is_found ) { go_BYE(-1); }
    goto BYE;
  }
  if ( ( val.num_elements == 0 ) && ( val.num_chnks != 0 ) ) { go_BYE(-1); }
  // Delete chunks in vector before deleting vector 
  for ( uint32_t chnk_idx = 0; chnk_idx <= val.max_chnk_idx; chnk_idx++ ){
    uint32_t old_nitems = g_chnk_hmap[tbsp].nitems;
    if ( old_nitems == 0 ) { 
      if ( val.is_err ) { 
        // Ignore the error 
      }
      else {
        go_BYE(-1); 
      }
    }
    bool is_found = true;
    status = chnk_del(tbsp, uqid, chnk_idx, is_persist); 
    if ( status == -3 ) { status = 0; is_found = false; } 
    cBYE(status);
    if ( val.memo_len < 0 ) {  
      // memo length infinite means all chunks must have been saved
      if ( !is_found ) {
        if ( val.is_err == true ) { 
          // Ignore this error 
        }
        else {
          if ( val.is_lma == false ) { 
            go_BYE(-1); 
          }
        }
      }
    }
    else {
      // we may have deleted chunks that are too 
      // The +1 is important here but needs more thought TODO P2
      uint32_t watermark = val.max_chnk_idx + 1 - val.memo_len;
      if ( chnk_idx >= watermark ) {
        if ( !is_found ) { go_BYE(-1); }
      }
      else {
        // more thought needed on the > or >= TODO P2 
        if ( chnk_idx > watermark ) {
        if ( is_found ) { 
          printf("Found chunk %u in [%s]. Should not have existed\n", 
              chnk_idx, val_name);
          // go_BYE(-1); 
        }
        }
      }
    }
    uint32_t new_nitems = g_chnk_hmap[tbsp].nitems;
    if ( is_found ) { 
      if ( new_nitems != (old_nitems-1) ) { go_BYE(-1); }
    }
  }
  bool is_found;
  vctr_rs_hmap_key_t key = uqid; 
  status = g_vctr_hmap[0].del(&g_vctr_hmap[tbsp], &key, &val, &is_found); 
  cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  uint64_t mem_used, dsk_used;
  status = vctr_usage(tbsp, uqid, &mem_used, &dsk_used); cBYE(status);
  if ( mem_used != 0 ) { go_BYE(-1); } 
  if ( dsk_used != 0 ) { go_BYE(-1); } 
BYE:
  if ( status < 0 ) { 
    printf("Error in deleting Vector %s \n", val.name);
  }
  free_if_non_null(lma_file);
  free_if_non_null(val_name);
  return status;
}
