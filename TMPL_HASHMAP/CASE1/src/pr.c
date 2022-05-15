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
  fprintf(fp, "%" PRIu64 "", *ptr_key);
}

void 
pr_val(
    rs_hmap_val_t *ptr_val,
    FILE *fp
    )
{
  fprintf(fp, "%u", *ptr_val);
}
