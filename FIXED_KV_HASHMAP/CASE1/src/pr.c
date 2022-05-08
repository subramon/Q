#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include "hmap_struct.h"
#include "pr.h"

void 
pr_key(
    hmap_key_t *ptr_key,
    FILE *fp
    )
{
  fprintf(fp, "%llu", *ptr_key);
}

void 
pr_val(
    hmap_val_t *ptr_val,
    FILE *fp
    )
{
  fprintf(fp, "%lu", *ptr_val);
}
