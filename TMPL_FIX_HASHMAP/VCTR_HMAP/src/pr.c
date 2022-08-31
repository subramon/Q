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
  fprintf(fp, "%" PRIu32 "", *ptr_key);
}

void 
pr_val(
    rs_hmap_val_t *ptr_val,
    FILE *fp
    )
{
  fprintf(fp, "nE = %" PRIu64 "\n", ptr_val->num_elements);
  fprintf(fp, "nC = %" PRIu32 "\n", ptr_val->num_chunks);
  fprintf(fp, "is_eov = %s \n", ptr_val->is_eov ? "true" : "false" );
  fprintf(fp, "is_trash = %s \n", ptr_val->is_trash ? "true" : "false" );
}
