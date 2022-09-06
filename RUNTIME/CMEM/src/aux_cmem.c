#include "q_incs.h"
#include "cmem_struct.h"
#include "aux_cmem.h"
int 
cmem_free( 
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  memset(ptr_cmem->cell_name, 0, Q_MAX_LEN_CELL_NAME+1); 
  if ( ptr_cmem->data == NULL ) { 
    // explicit free will cause control to come here
    if ( ptr_cmem->size != 0 ) {
      go_BYE(-1); 
    }
  }
  else {
    if ( ptr_cmem->is_foreign ) { 
      /* Foreign indicates somebody else responsible for free */
    }
    else {
      // garbage collection of Lua
      if ( ptr_cmem->size == 0 ) {
        /* nothing to do */
        go_BYE(-1);
      }
      free_if_non_null(ptr_cmem->data);
      ptr_cmem->size = 0;
    }
  }
BYE:
  return status;
}
