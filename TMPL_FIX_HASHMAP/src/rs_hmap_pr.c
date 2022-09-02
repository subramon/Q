// EXTERNAL EXPOSURE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rs_hmap_struct.h"
#include "rsx_pr.h"
#include "rs_hmap_pr.h"
int
rs_hmap_pr(
    rs_hmap_t *ptr_hmap,
    FILE *fp
    )
{
  int status = 0;
  rs_hmap_bkt_t *bkts = ptr_hmap->bkts;
  bool *bkt_full = ptr_hmap->bkt_full;
  if ( fp == NULL ) { fp = stdout; }
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( !bkt_full[i] ) { continue; }
    fprintf(fp, ",");
    rsx_pr_key(bkts+i, fp); cBYE(status);
    rsx_pr_val(bkts+i, fp); cBYE(status);
    fprintf(fp, "\n");
  }
BYE:
  return status;
}
