// EXTERNAL EXPOSURE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "pr.h"
#include "rs_hmap_pr.h"
int
rs_hmap_pr(
    rs_hmap_t *ptr_hmap,
    FILE *fp
    )
{
  int status = 0;
  bkt_t *bkts = (bkt_t *)ptr_hmap->bkts;
  bool *bkt_full = ptr_hmap->bkt_full;
  if ( fp == NULL ) { fp = stdout; }
  for ( uint32_t i = 0; i < ptr_hmap->size; i++ ) { 
    if ( !bkt_full[i] ) { continue; }
    pr_key(&(bkts[i].key), fp); cBYE(status);
    pr_val(&(bkts[i].val), fp); cBYE(status);
  }
BYE:
  return status;
}
