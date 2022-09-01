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
  fprintf(fp, "(%" PRIu32 ", %d)", ptr_key->vctr_uqid, ptr_key->chnk_idx);
}

void 
pr_val(
    rs_hmap_val_t *ptr_val,
    FILE *fp
    )
{
  fprintf(fp, "%" PRIu32 "", ((uint32_t *)ptr_val)[0]);
}
