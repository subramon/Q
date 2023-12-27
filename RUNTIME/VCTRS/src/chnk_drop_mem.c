#include "q_incs.h"
#include "q_macros.h"
#include "vctr_consts.h"

#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "chnk_drop_mem.h"
#include "mod_mem_used.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;
// It eliminates memory at level "level" if possible. 
int  
chnk_drop_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    int level
    )
{
  int status = 0;
  char *l2_file = NULL; FILE *fp = NULL;
  bool chnk_is_found; uint32_t chnk_where_found;
  bool vctr_is_found; uint32_t vctr_where_found;
  char *X = NULL; size_t nX = 0;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t *ptr_vctr =
    &(g_vctr_hmap[tbsp].bkts[vctr_where_found].val);
  bool is_lma = ptr_vctr->is_lma;

  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,
      &chnk_where_found);
  cBYE(status);
  if ( !chnk_is_found ) { go_BYE(-1); }

  chnk_rs_hmap_val_t *ptr_chnk =
    &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);

  switch ( level ) { 
    case 1 : 
      if ( ptr_chnk->l1_mem == NULL ) { goto BYE; } // nothing to do 
      if ( !ptr_chnk->l2_exists) { 
        if ( is_lma ) { 
          // we can restore this data from the vector file 
        }
        else { 
          // make l2 before deleting l1 
          l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
          fp = fopen(l2_file, "wb");
          fwrite(ptr_chnk->l1_mem, ptr_chnk->size, 1, fp);
          fclose_if_non_null(fp);
          status = incr_dsk_used(ptr_chnk->size); cBYE(status);
          ptr_chnk->l2_exists = true;
        }
      }
      free_if_non_null(ptr_chnk->l1_mem);
      status = decr_mem_used(ptr_chnk->size); cBYE(status);
      break;
      //--------------------------------------------------
    case 2 : 
      // Do not delete files from other table spaces
      if ( tbsp != 0 ) { goto BYE; }  // NOTE Not an error 
      if ( !ptr_chnk->l2_exists) { goto BYE; } // nothing to do 

      l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
      if ( l2_file == NULL )  { go_BYE(-1); }
      if ( ptr_chnk->l1_mem == NULL ) { 
        if ( is_lma ) { 
          // we can resurrect data from vector file 
        }
        else { 
          // make l1 before deleting l2
          status = rs_mmap(l2_file, &X, &nX, 0); 
          if ( nX != ptr_chnk->size ) { go_BYE(-1); }
          status = posix_memalign((void **)&(ptr_chnk->l1_mem), 
              Q_VCTR_ALIGNMENT, ptr_chnk->size);
          cBYE(status);
          memcpy(ptr_chnk->l1_mem, X, nX); 
          munmap(X, nX); X = NULL; nX = 0;
          status = incr_mem_used(ptr_chnk->size); cBYE(status);
#ifdef VERBOSE
          printf("%s Allocated %u \n", __FILE__, ptr_chnk->size);
#endif
        }
        status = unlink(l2_file); cBYE(status); 
        status = decr_dsk_used(ptr_chnk->size); cBYE(status);
        ptr_chnk->l2_exists = false; 
      }
      break;
      //-----------------
    default : 
      go_BYE(-1);
      break;
  }
BYE:
  free_if_non_null(l2_file);
  if ( X != NULL ) { munmap(X, nX); } 
  fclose_if_non_null(fp);
  return status; 
}
// tells us whether chunk has backup at levels 1 or 2 
int  
chnk_is_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    bool *ptr_has_mem
    )
{
  int status = 0;
  bool chnk_is_found; uint32_t chnk_where_found;
  bool vctr_is_found; uint32_t vctr_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }

  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,
      &chnk_where_found);
  cBYE(status);
  if ( !chnk_is_found ) { go_BYE(-1); }

  chnk_rs_hmap_val_t *ptr_chnk =
    &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);

  *ptr_has_mem = false;
  if ( ( ptr_chnk->l1_mem != NULL ) || ( ptr_chnk->l2_exists) ) {
    *ptr_has_mem = true;
  }
BYE:
  return status; 
}
