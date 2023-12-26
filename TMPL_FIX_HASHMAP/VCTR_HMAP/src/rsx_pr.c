#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  ${tmpl}_rs_hmap_bkt_t *bkts = (${tmpl}_rs_hmap_bkt_t *)in_bkts;
  ${tmpl}_rs_hmap_key_t *ptr_key = &(bkts[idx].key);
  fprintf(fp, "%" PRIu32 "", *ptr_key);
}

void 
rsx_pr_val(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  ${tmpl}_rs_hmap_bkt_t *bkts = (${tmpl}_rs_hmap_bkt_t *)in_bkts;
  ${tmpl}_rs_hmap_val_t *ptr_val = &(bkts[idx].val);
  fprintf(fp, "nE = %" PRIu64 "\n", ptr_val->num_elements);
  fprintf(fp, "nC = %" PRIu32 "\n", ptr_val->num_chnks);
  fprintf(fp, "nS = %" PRIu32 "\n", ptr_val->max_num_in_chnk);
  fprintf(fp, "is_eov = %s \n", ptr_val->is_eov ? "true" : "false" );
}
