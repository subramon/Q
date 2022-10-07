#include "q_incs.h"
#include "q_macros.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "chnk_l1_to_l2.h"
#include "mod_mem_used.h"

extern chnk_rs_hmap_t g_chnk_hmap;
int  
chnk_l1_to_l2(
  uint32_t chnk_where
    )
{
  int status = 0;
  char *l2_file = NULL; FILE *fp = NULL;
  char *X = NULL; size_t nX = 0;
  chnk_rs_hmap_key_t *ptr_key = &(g_chnk_hmap.bkts[chnk_where].key);
  chnk_rs_hmap_val_t *ptr_val = &(g_chnk_hmap.bkts[chnk_where].val);

  l2_file = l2_file_name(ptr_key->vctr_uqid, ptr_key->chnk_idx);
  if ( l2_file == NULL ) { go_BYE(-1); }
  if ( isfile(l2_file) ) { 
    /* Nothing to d; backup has occurred */
    goto BYE; 
  }
  //--------------------------------------------------
  if ( ptr_val->l1_mem == NULL ) { 
    go_BYE(-1); // data is not in l1 nor in l2 
  }
  //--------------------------------------------------
  fp = fopen(l2_file, "wb"); 
  size_t nr = fwrite(ptr_val->l1_mem, ptr_val->size, 1, fp);
  if ( nr != 1 ) { go_BYE(-1); }
  fclose_if_non_null(fp);
  printf("writing to %s \n", l2_file);
  status = incr_dsk_used(ptr_val->size); cBYE(status);
  ptr_val->l2_exists = true; 

BYE:
  free_if_non_null(l2_file);
  fclose_if_non_null(fp);
  if ( X != NULL ) { munmap(X, nX);  }
  return status; 
}
