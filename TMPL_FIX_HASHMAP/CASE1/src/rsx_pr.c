#include "q_incs.h"
#include "q_macros.h"
#include "rs_hmap_int_struct.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  bkt_t *bkts = (bkt_t *)in_bkts;
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
  bkt_t *bkts = (bkt_t *)in_bkts;
  fprintf(fp, "%u", bkts[idx].val);
}
