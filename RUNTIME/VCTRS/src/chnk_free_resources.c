#include "q_incs.h"
#include "qtypes.h"
#include "isfile.h"
#include "chnk_rs_hmap_struct.h"
#include "mod_mem_used.h"
#include "l2_file_name.h"
#include "chnk_free_resources.h"

int 
chnk_free_resources(
    chnk_rs_hmap_key_t *ptr_key,
    chnk_rs_hmap_val_t *ptr_val,
    bool is_persist
    )
{
  int status = 0;
  char * l2_file = NULL;
  //---------------------------------------------------
  if ( ptr_val->l1_mem != NULL ) { 
    free_if_non_null(ptr_val->l1_mem);
    status = decr_mem_used(ptr_val->size); cBYE(status);
  }
  // TODO P3 If it takes time to free resources, we should
  // put this in a shared memory queue for the memory manager to deal with
  //---------------------------------------------------
  if ( is_persist == false ) { 
    if ( ptr_val->l2_exists ) {
      l2_file = l2_file_name(ptr_key->vctr_uqid, ptr_key->chnk_idx);
      if ( l2_file == NULL ) { go_BYE(-1); }
      if ( !isfile (l2_file) ) { go_BYE(-1); }
      status = unlink(l2_file); cBYE(status);
      status = decr_dsk_used(ptr_val->size); cBYE(status);
      ptr_val->l2_exists = false;
    }
  }
BYE:
  free_if_non_null(l2_file); 
  return status;
}
