// update the value 
#include "val_struct.h"
#include "val_update.h"
int
val_update(
    val_t *ptr_dst_val,
    val_t *ptr_src_val
    )
{
  *ptr_dst_val = *ptr_src_val;
  return 0;
}
