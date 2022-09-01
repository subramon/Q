#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "rs_hmap_int_struct.h"
#include "pr.h"

void 
pr_key(
    bkt_t *bkts,
    uint32_t idx,
    FILE *fp
    )
{
  fprintf(fp, "%" PRIu64 "", bkts[idx].key);
}

void 
pr_val(
    bkt_t *bkts,
    uint32_t idx,
    FILE *fp
    )
{
  fprintf(fp, "%u", bkts[idx].val);
}
