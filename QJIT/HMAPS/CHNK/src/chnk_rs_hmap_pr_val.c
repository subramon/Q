#include <stdio.h>
#include <stdint.h>
#include "macros.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_pr_val.h"

//START_FUNC_DECL
int 
chnk_rs_hmap_pr_val(
    chnk_rs_hmap_val_t *ptr_val,
    FILE *fp
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); } 
  fprintf(fp, "(qtype=%u;num_elements=%u)", 
      ptr_val->qtype, // TODO Make this a string using utils
      ptr_val->num_elements);
BYE:
  return status;
}
