// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_struct_1.h"
#include "val_update.h"

// extern int num_mallocs;
// extern int num_frees;

int
val_update(
    void **ptr_dst_val,
    void *ptr_src_val
    )
{
  int status = 0;

  if ( ptr_dst_val == NULL ) { go_BYE(-1); }
  if ( ptr_src_val == NULL ) { go_BYE(-1); }

  // if ( *ptr_dst_val != NULL ) { num_frees++; }
  free_if_non_null(*ptr_dst_val); 
  val_t src_val = *((val_t *)ptr_src_val);
  val_t *dst_val = malloc(sizeof(val_t));
  // printf("malloc'd %" PRIu64 "\n", ((uint64_t *)dst_val)); 
  // num_mallocs++;
  return_if_malloc_failed(dst_val);
  *dst_val = src_val; 
  *ptr_dst_val = dst_val;
BYE:
  return status;
}
