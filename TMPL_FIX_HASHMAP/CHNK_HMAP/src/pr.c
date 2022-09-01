#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "rs_hmap_int_struct.h"
#include "pr.h"

void 
pr_key(
    rs_hmap_key_t *ptr_key,
    FILE *fp
    )
{
  fprintf(fp, "%" PRIu32 "", *ptr_key);
}

void 
pr_val(
    rs_hmap_val_t *ptr_val,
    FILE *fp
    )
{
  fprintf(fp, "nR = %" PRIu64 "\n", ptr_val->num_readers);
  fprintf(fp, "nW = %" PRIu32 "\n", ptr_val->num_writers);
  fprintf(fp, "V  = %" PRIu32 "\n", ptr_val->vctr_uqid);
  fprintf(fp, "C  = %" PRIu32 "\n", ptr_val->chnk_idx );
  fprintf(fp, "n  = %" PRIu32 "\n", ptr_val->num_elements );
  fprintf(fp, "s  = %" PRIu32 "\n", ptr_val->size );
  fprintf(fp, "M = %s \n", ptr_val->l1_mem != NULL ? "true" : "false" );
}
