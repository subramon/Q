#include "rsx_types.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_key,
    FILE *fp
    )
{
  vctr_rs_hmap_key_t *ptr_key = (vctr_rs_hmap_key_t *)in_key;
  fprintf(fp, "%" PRIu32 "", *ptr_key);
}

void 
rsx_pr_val(
    void *in_val,
    FILE *fp
    )
{
  vctr_rs_hmap_val_t *ptr_val = (vctr_rs_hmap_val_t *)in_val;
  fprintf(fp, "nE = %" PRIu64 "\n", ptr_val->num_elements);
  fprintf(fp, "nC = %" PRIu32 "\n", ptr_val->num_chnks);
  fprintf(fp, "nS = %" PRIu32 "\n", ptr_val->max_num_in_chnk);
  fprintf(fp, "is_eov = %s \n", ptr_val->is_eov ? "true" : "false" );
  fprintf(fp, "is_trash = %s \n", ptr_val->is_trash ? "true" : "false" );
}
