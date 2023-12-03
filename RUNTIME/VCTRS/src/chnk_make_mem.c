#include "q_incs.h"
#include "q_macros.h"
#include "qjit_consts.h"
#include "vctr_consts.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "chnk_is.h"
#include "mod_mem_used.h"
#include "chnk_make_mem.h"

extern chnk_rs_hmap_t *g_chnk_hmap;
// It creates memory at level "level" if necessary
int  
chnk_make_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    int level 
    )
{
  int status = 0;
  char *l2_file = NULL; FILE *fp = NULL;
  char *X = NULL; size_t nX = 0;
  // cannot backup chunk if not in your tablespace
  if ( tbsp != 0 ) { go_BYE(-1); } 

  bool chnk_is_found; uint32_t chnk_where_found;
  status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,
      &chnk_where_found);
  cBYE(status);
  if ( !chnk_is_found ) { go_BYE(-1); }

  chnk_rs_hmap_val_t *ptr_val =
    &(g_chnk_hmap[tbsp].bkts[chnk_where_found].val);

  l2_file = l2_file_name(tbsp, vctr_uqid, chnk_idx);
  if ( l2_file == NULL ) { go_BYE(-1); } 
  switch ( level ) {
    case 1 : 
      if ( ptr_val->l1_mem != NULL ) { /* nothing to do  */ goto BYE; }

      if ( !isfile(l2_file) ) { go_BYE(-1); } 
      status = rs_mmap(l2_file, &X, &nX, 0); cBYE(status);
      if ( nX != ptr_val->size ) { go_BYE(-1); }
      status = posix_memalign((void **)&(ptr_val->l1_mem), 
          Q_VCTR_ALIGNMENT, ptr_val->size);
      cBYE(status);
      memcpy(ptr_val->l1_mem, X, nX); 
      incr_mem_used(ptr_val->size); 
#ifdef VERBOSE
      printf("%s Allocated %u \n", __FILE__, ptr_val->size);
#endif
      break;
    case 2 : 
      if ( ptr_val->l2_exists ) { /* nothing to do  */ goto BYE; }

      if ( isfile(l2_file) ) { go_BYE(-1); } 
      fp = fopen(l2_file, "wb"); 
      size_t nr = fwrite(ptr_val->l1_mem, ptr_val->size, 1, fp);
      if ( nr != 1 ) { go_BYE(-1); }
      fclose_if_non_null(fp);
      status = incr_dsk_used(ptr_val->size); cBYE(status);
      ptr_val->l2_exists = true; 
#ifdef VERBOSE
        printf("%s Disk Usage up by %u \n", __FILE__, ptr_val->size);
#endif
      break;
    default : 
      go_BYE(-1);
      break;
  }
BYE:
  free_if_non_null(l2_file);
  fclose_if_non_null(fp);
  if ( X != NULL ) { munmap(X, nX);  }
  return status; 
}
