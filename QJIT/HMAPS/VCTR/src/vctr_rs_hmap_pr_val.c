#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "macros.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_pr_val.h"

//START_FUNC_DECL
int 
vctr_rs_hmap_pr_val(
    vctr_rs_hmap_val_t *ptr_val,
    FILE *fp
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); } 
  fprintf(fp, "(name=%s;qtype=%s,num_elements=%" PRIu64 ",nC=%u)", 
      ptr_val->name, 
      get_str_qtype(ptr_val->qtype),
      ptr_val->num_elements,
      ptr_val->max_num_in_chnk);
BYE:
  return status;
}
