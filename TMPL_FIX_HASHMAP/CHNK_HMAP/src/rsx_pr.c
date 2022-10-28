#include "rsx_types.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_key,
    FILE *fp
    )
{
  chnk_rs_hmap_key_t *ptr_key = ( chnk_rs_hmap_key_t *)in_key;
  fprintf(fp, "(%u,%u)", ptr_key->vctr_uqid, ptr_key->chnk_idx);
}

void 
pr_val(
    void *in_val,
    FILE *fp
    )
{
  chnk_rs_hmap_val_t *ptr_val = ( chnk_rs_hmap_val_t *)in_val;
  fprintf(fp, "nR = %" PRIu64 "\n", ptr_val->num_readers);
  fprintf(fp, "nW = %" PRIu32 "\n", ptr_val->num_writers);
  fprintf(fp, "n  = %" PRIu32 "\n", ptr_val->num_elements );
  fprintf(fp, "s  = %" PRIu32 "\n", ptr_val->size );
  fprintf(fp, "M = %s \n", ptr_val->l1_mem != NULL ? "true" : "false" );
}
