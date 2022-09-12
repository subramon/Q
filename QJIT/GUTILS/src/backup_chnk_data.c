#include "q_incs.h"
#include "q_macros.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "l2_file_name.h"
#include "backup_chnk_data.h"

char *
backup_chnk_data(
    chnk_rs_hmap_key_t *ptr_key,
    chnk_rs_hmap_val_t *ptr_chnk
    )
{
  int status = 0;
  char *l2_file = NULL; FILE *fp = NULL;
  char *X = NULL; size_t nX = 0;

  l2_file = l2_file_name(ptr_key->vctr_uqid, ptr_key->chnk_idx);
  if ( l2_file == NULL ) { go_BYE(-1); }
  if ( ( isfile(l2_file) )  && ( ptr_chnk->l2_dirty == false ) ) {
    /* Nothing to d; backup has occurred */
    goto BYE; 
  }
  //--------------------------------------------------
  if ( ptr_chnk->l1_mem == NULL ) { 
    go_BYE(-1); // data is not in l1 nor in l2 
  }
  //--------------------------------------------------
  if ( ptr_chnk->l2_mem_id == 0 ) { 
    ptr_chnk->l2_mem_id = RDTSC(); 
    // TODO P2 Above must be unique. Make sure it is 
  }
  fp = fopen(l2_file, "wb"); 
  size_t nr = fwrite(ptr_chnk>l1_mem, ptr_chnk->size, 1, fp);
  if ( nr != 1 ) { go_BYE(-1); }
  fclose_if_non_null(fp);

BYE:
  free_if_non_null(l2_file);
  fclose_if_non_null(fp);
  if ( X != NULL ) { munmap(X, nX);  }
  return status; 
}
