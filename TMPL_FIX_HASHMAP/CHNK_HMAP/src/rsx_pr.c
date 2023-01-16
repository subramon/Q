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
  fprintf(fp, "(%u,%u)", ptr_key->vctr_uqid, ptr_key->${tmpl}_idx);
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
  fprintf(fp, "nR = %" PRIi32 "\n", ptr_val->num_readers);
  fprintf(fp, "nW = %" PRIu32 "\n", ptr_val->num_writers);
  fprintf(fp, "n  = %" PRIu32 "\n", ptr_val->num_elements );
  fprintf(fp, "s  = %" PRIu32 "\n", ptr_val->size );
  fprintf(fp, "M = %s \n", ptr_val->l1_mem != NULL ? "true" : "false" );
}
