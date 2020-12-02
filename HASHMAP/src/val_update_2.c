// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_update.h"
int
val_update(
    val_t *ptr_dst_val,
    val_t *ptr_src_val
    )
{
  int status = 0;
  if ( ptr_dst_val == NULL ) { go_BYE(-1); }
  if ( ptr_src_val == NULL ) { go_BYE(-1); }
  *ptr_dst_val = *ptr_src_val;
BYE:
  return status;
}
