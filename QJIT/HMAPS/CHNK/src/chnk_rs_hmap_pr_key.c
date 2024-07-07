#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "macros.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_pr_key.h"

//START_FUNC_DECL
int
chnk_rs_hmap_pr_key(
    chnk_rs_hmap_key_t *ptr_key,
    FILE *fp
    )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_key == NULL ) { go_BYE(-1); } 
  fprintf(fp, "(VCTR_UQID=%u;CHNK_IDX=%u)", 
      ptr_key->vctr_uqid, ptr_key->chnk_idx);
BYE:
  return status;
}
