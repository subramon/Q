#include "q_incs.h"
#include "q_macros.h"
#include "rsx_types.h"
#include "rsx_pr.h"

void 
rsx_pr_key(
    void *in_key,
    FILE *fp
    )
{
  if ( in_key == NULL ) { WHEREAMI; return; }
  rs_hmap_key_t *key = (rs_hmap_key_t *)in_key;
  fprintf(fp, "%" PRIu64 "", *key);
}

void 
rsx_pr_val(
    void *in_val,
    FILE *fp
    )
{
  if ( in_val == NULL ) { WHEREAMI; return; }
  rs_hmap_val_t *val = (rs_hmap_val_t *)in_val;
  fprintf(fp, "%" PRIu32 "", *val);
}
