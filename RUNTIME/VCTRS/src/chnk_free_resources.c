#include "q_incs.h"
#include "qtypes.h"
#include "isfile.h"
#include "chnk_rs_hmap_struct.h"
#include "mod_mem_used.h"
#include "l2_file_name.h"
#include "chnk_free_resources.h"

int 
chnk_free_resources(
    uint32_t chnk_size,
    chnk_rs_hmap_val_t *ptr_chnk
    )
{
  int status = 0;
  if ( ptr_chnk->l1_mem != NULL ) { 
    free_if_non_null(ptr_chnk->l1_mem);
    status = decr_mem_used(chnk_size); cBYE(status);
  }
  // TODO P3 If it takes time to free resources, we should
  // put this in a shared memory queue for the memory manager to deal with
  if ( ptr_chnk->l2_mem_id != 0 ) { // delete L2 storage for chunk
    char * l2_file = l2_file_name(ptr_chnk->l2_mem_id);
    if ( l2_file != NULL ) { 
      if ( isfile (l2_file) ) {
        status = unlink(l2_file);
        if ( status != 0 ) { WHEREAMI; status = 0; }
      }
    }
    free_if_non_null(l2_file); 
  }
BYE:
  return status;
}
