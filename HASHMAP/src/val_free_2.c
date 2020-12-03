// update the value 
#include "q_incs.h"
#include "q_macros.h"
#include "val_struct_2.h"
#include "val_free.h"
extern int num_frees; extern int num_mallocs;
int
val_free(
    void **ptr_val
    )
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); }
  val_t *V = *ptr_val;
  if ( V->len <= 0 ) { go_BYE(-1); }
  free_if_non_null(V->str);
  V->len = 0;
  free_if_non_null(V);
  *ptr_val = NULL;
BYE:
  return status;
}
