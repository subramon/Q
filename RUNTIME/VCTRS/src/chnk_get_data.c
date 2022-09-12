#include "q_incs.h"
#include "q_macros.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "vctr_consts.h"
#include "mod_mem_used.h"
#include "chnk_get_data.h"

char *
chnk_get_data(
    chnk_rs_hmap_key_t *ptr_key,
    chnk_rs_hmap_val_t *ptr_chnk,
    bool is_write
    )
{
  int status = 0;
  char *l2_file = NULL;
  char *X = NULL; size_t nX = 0;

  if ( is_write ) { 
    if ( ptr_chnk->num_readers > 0 ) { go_BYE(-1); }
    if ( ptr_chnk->num_writers > 0 ) { go_BYE(-1); }
    ptr_chnk->num_writers = 1;
  }
  else {
    if ( ptr_chnk->num_writers > 0 ) { go_BYE(-1); }
    ptr_chnk->num_readers++;
  }

  if ( ptr_chnk->l1_mem == NULL ) {
    // try and get it from l2 mem 
    l2_file = l2_file_name(ptr_key->vctr_uqid, ptr_key->chnk_idx);
    if ( l2_file == NULL ) { go_BYE(-1); }
    status = rs_mmap(l2_file, &X, &nX, is_write); cBYE(status);
    if ( nX != ptr_chnk->size ) { go_BYE(-1); }
    status = posix_memalign((void **)&(ptr_chnk->l1_mem), 
      Q_VCTR_ALIGNMENT, ptr_chnk->size);
    cBYE(status);
    memcpy(ptr_chnk->l1_mem, X, nX); 
    incr_mem_used(ptr_chnk->size);
  }
  char *data  = ptr_chnk->l1_mem; 
  if ( data == NULL ) { go_BYE(-1); }
BYE:
  free_if_non_null(l2_file);
  if ( X != NULL ) { munmap(X, nX);  }
  if ( status == 0 ) { return data; } else { return NULL; }
}
