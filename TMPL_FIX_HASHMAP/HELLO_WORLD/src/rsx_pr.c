#include "q_incs.h"
#include "q_macros.h"
#include "hw_rs_hmap_struct.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  hw_rs_hmap_bkt_t *bkts = (hw_rs_hmap_bkt_t *)in_bkts;
  fprintf(fp, "%" PRIu64 "", bkts[idx].key);
}

void 
rsx_pr_val(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  hw_rs_hmap_bkt_t *bkts = (hw_rs_hmap_bkt_t *)in_bkts;
  fprintf(fp, "%u", bkts[idx].val);
}
