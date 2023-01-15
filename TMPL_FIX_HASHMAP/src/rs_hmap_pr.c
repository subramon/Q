// EXTERNAL EXPOSURE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rs_hmap_struct.h"
#include "_rs_hmap_pr.h"
int
rs_hmap_pr(
    ${tmpl}_rs_hmap_t *ptr_hmap,
    FILE *fp
    )
{
  int status = 0;
  void *bkts = ptr_hmap->bkts;
  bool *bkt_full = ptr_hmap->bkt_full;
  if ( fp == NULL ) { fp = stdout; }
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( !bkt_full[i] ) { continue; }
    ptr_hmap->pr_key(bkts, i, fp); 
    fprintf(fp, ",");
    ptr_hmap->pr_val(bkts, i, fp);
    fprintf(fp, "\n");
  }
BYE:
  return status;
}
