// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_struct_2.h"
#include "val_update.h"

extern int num_mallocs; extern int num_frees;

int
val_update(
    void **ptr_dst_val,
    void *ptr_src_val
    )
{
  int status = 0;

  if ( ptr_dst_val == NULL ) { go_BYE(-1); }
  if ( ptr_src_val == NULL ) { go_BYE(-1); }

  if ( *ptr_dst_val != NULL ) { num_frees++; }
  free_if_non_null(*ptr_dst_val); 
  val_t src_val = *((val_t *)ptr_src_val);
  int len = src_val.len;
  char *str = src_val.str;
  if ( len == 0 ) { go_BYE(-1); }
  if ( str == 0 ) { go_BYE(-1); }
  val_t *dst_val = malloc(sizeof(val_t));
  return_if_malloc_failed(dst_val);
  dst_val->str = malloc(len);
  return_if_malloc_failed(dst_val->str);
  memcpy(dst_val->str, str, len);
  dst_val->len = len;
  num_mallocs++;
  // printf("malloc'd %" PRIu64 "\n", ((uint64_t *)dst_val)); 
  *ptr_dst_val = dst_val;
BYE:
  return status; }
