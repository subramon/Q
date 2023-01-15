#include "q_incs.h"
#include "q_macros.h"
#include "rs_hmap_struct.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  hw2_rs_hmap_bkt_t *bkts = (hw2_rs_hmap_bkt_t *)in_bkts;
  fprintf(fp, "%lf", bkts[idx].key.f8);
}

void 
rsx_pr_val(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  hw2_rs_hmap_bkt_t *bkts = (hw2_rs_hmap_bkt_t *)in_bkts;
  fprintf(fp, "%s", bkts[idx].val.str);
}
