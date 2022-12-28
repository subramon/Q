#include "q_incs.h"
#include "q_macros.h"
#include "qjit_consts.h"

#include "chnk_rs_hmap_struct.h"
#include "rs_mmap.h"
#include "l2_file_name.h"
#include "vctr_consts.h"
#include "mod_mem_used.h"
#include "chnk_get_data.h"

extern chnk_rs_hmap_t *g_chnk_hmap;

char *
chnk_get_data(
    uint32_t tbsp,
    uint32_t chnk_where,
    bool is_write
    )
{
  int status = 0;
  char *l2_file = NULL;
  char *X = NULL; size_t nX = 0;
  chnk_rs_hmap_key_t *ptr_key = &(g_chnk_hmap[tbsp].bkts[chnk_where].key);
  chnk_rs_hmap_val_t *ptr_val = &(g_chnk_hmap[tbsp].bkts[chnk_where].val);

  if ( ptr_val->is_early_free ) { 
    if ( ptr_val->num_readers > 0 ) { go_BYE(-1); }
    if ( ptr_val->num_writers > 0 ) { go_BYE(-1); }
    return NULL;
  }
  //-----------------------------------------
  if ( is_write ) { 
    if ( ptr_val->num_readers > 0 ) { go_BYE(-1); }
    if ( ptr_val->num_writers > 0 ) { go_BYE(-1); }
    ptr_val->num_writers = 1;
  }
  else {
    if ( ptr_val->num_writers > 0 ) { go_BYE(-1); }
    ptr_val->num_readers++;
  }

  if ( ptr_val->l1_mem == NULL ) {
    // try and get it from l2 mem 
    l2_file = l2_file_name(tbsp, ptr_key->vctr_uqid, ptr_key->chnk_idx);
    if ( l2_file == NULL ) { go_BYE(-1); }
    status = rs_mmap(l2_file, &X, &nX, is_write); cBYE(status);
    if ( nX != ptr_val->size ) { go_BYE(-1); }
    status = posix_memalign((void **)&(ptr_val->l1_mem), 
      Q_VCTR_ALIGNMENT, ptr_val->size);
    cBYE(status);
    memcpy(ptr_val->l1_mem, X, nX); 
    incr_mem_used(ptr_val->size);
  }
  char *data  = ptr_val->l1_mem; 
  if ( data == NULL ) { go_BYE(-1); }
BYE:
  free_if_non_null(l2_file);
  if ( X != NULL ) { munmap(X, nX);  }
  if ( status == 0 ) { return data; } else { return NULL; }
}
