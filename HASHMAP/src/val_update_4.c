// update the value 
#include "q_incs.h"
#include <limits.h>
#include <float.h>
#include "q_macros.h"
#include "val_struct_4.h"
#include "val_update.h"

#ifdef DEBUG
extern int num_updates;
extern int num_mallocs;
extern int num_frees;
#endif

int
val_update(
    void **in_ptr_dst_val,
    void *in_ptr_src_val
    )
{
  int status = 0;

#ifdef DEBUG
  num_updates++;
  if ( in_ptr_dst_val == NULL ) { go_BYE(-1); }
  if ( in_ptr_src_val == NULL ) { go_BYE(-1); }
#endif
  val_t    **ptr_dst_val = (   val_t **)in_ptr_dst_val;
  in_val_t **ptr_src_val = (in_val_t **)in_ptr_src_val;
  in_val_t src_val = *((in_val_t *)ptr_src_val);

  if ( *ptr_dst_val == NULL ) { 
    *ptr_dst_val = malloc(sizeof(val_t));
    return_if_malloc_failed(*ptr_dst_val);
    memset(*ptr_dst_val, 0,  (sizeof(val_t)));
    (*ptr_dst_val)->minval = FLT_MAX;
    (*ptr_dst_val)->maxval = -1 * FLT_MAX;
#ifdef DEBUG
    num_mallocs++;
#endif
  }
  val_t *dst_val = *ptr_dst_val;
  dst_val[0].cnt++;
  dst_val[0].sumval += src_val;
  if ( dst_val[0].minval > src_val ) { dst_val[0].minval = src_val; }
  if ( dst_val[0].maxval < src_val ) { dst_val[0].maxval = src_val; }

BYE:
  return status;
}
