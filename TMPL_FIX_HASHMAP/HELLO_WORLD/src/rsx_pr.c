#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "q_macros.h"
#include "${tmpl}_rs_hmap_struct.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_bkts,
    uint32_t idx,
    FILE *fp
    )
{
  if ( in_bkts == NULL ) { WHEREAMI; return; }
  ${tmpl}_rs_hmap_bkt_t *bkts = (${tmpl}_rs_hmap_bkt_t *)in_bkts;
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
  ${tmpl}_rs_hmap_bkt_t *bkts = (${tmpl}_rs_hmap_bkt_t *)in_bkts;
  fprintf(fp, "%u", bkts[idx].val);
}
