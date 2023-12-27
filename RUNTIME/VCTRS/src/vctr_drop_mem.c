#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "l2_file_name.h"
#include "file_exists.h"
#include "get_file_size.h"
#include "mod_mem_used.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_drop_mem.h"
#include "chnk_drop_mem.h"

// It eliminates memory at level "level" if possible. 
extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_drop_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int level
    )
{
  int status = 0;
  char *lma_file = NULL;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( ( level < 1 ) || ( level > 3 ) ) { go_BYE(-1); } 

  bool vctr_is_found; uint32_t vctr_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  uint32_t num_chnks=g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_chnks;

  if ( level == 3 ) {
    vctr_rs_hmap_val_t *ptr_vctr =
    &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val);
    if ( ptr_vctr->is_lma == false ) { 
      // Nothing to do since no memory exists at this level
      goto BYE;
    }
    else { // Make sure that all chunks can be resurrected
      bool all_mem = true; 
      for ( uint32_t chnk_idx = 0; chnk_idx < num_chnks; chnk_idx++ ) { 
        bool chnk_mem;
        status = chnk_is_mem(tbsp, vctr_uqid, chnk_idx, &chnk_mem); 
        cBYE(status);
        if ( chnk_mem == false ) { all_mem = false; break; }
      }
      if ( all_mem ) { // we can delete the lma file 
        lma_file = l2_file_name(0, vctr_uqid, ((uint32_t)~0));
        if ( lma_file == NULL ) { go_BYE(-1); }
        if ( !file_exists(lma_file) ) { go_BYE(-1); } 

        int64_t filesz = get_file_size(lma_file); 
        if ( filesz < 0 ) { go_BYE(-1); } 
        unlink(lma_file); 
        status = decr_dsk_used(filesz); 

        ptr_vctr->is_lma = false;
      }
      else {
        goto BYE; // nothing to do 
      }
    }
  }
  if ( level == 3 ) { goto BYE; } // all done
  // Control comes here => level in {1, 2}
  for ( uint32_t chnk_idx = 0; chnk_idx < num_chnks; chnk_idx++ ) { 
    status = chnk_drop_mem(tbsp, vctr_uqid, chnk_idx, level); 
    cBYE(status);
  }
BYE:
  free_if_non_null(lma_file); 
  return status;
}
