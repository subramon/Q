// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_struct_4.h"
#include "val_update.h"

extern int num_mallocs;
extern int num_frees;

int
val_update(
    void **in_ptr_dst_val,
    void *in_ptr_src_val
    )
{
  int status = 0;

  if ( in_ptr_dst_val == NULL ) { go_BYE(-1); }
  if ( in_ptr_src_val == NULL ) { go_BYE(-1); }
  val_t    **ptr_dst_val = (   val_t **)in_ptr_dst_val;
  in_val_t **ptr_src_val = (in_val_t **)in_ptr_src_val;
  in_val_t src_val = *((in_val_t *)ptr_src_val);

  if ( *ptr_dst_val == NULL ) { 
    *ptr_dst_val = malloc(sizeof(val_t));
    return_if_malloc_failed(*ptr_dst_val);
    memset(*ptr_dst_val, 0,  (sizeof(val_t)));
    num_mallocs++;
  }
  val_t *dst_val = *ptr_dst_val;
  dst_val[0].cnt++;
  dst_val[0].sumval += src_val;
  if ( dst_val[0].minval > src_val ) { dst_val[0].minval = src_val; }
  if ( dst_val[0].maxval < src_val ) { dst_val[0].maxval = src_val; }
BYE:
  return status;
}
