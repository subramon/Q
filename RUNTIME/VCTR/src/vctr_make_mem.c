#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_make_mem.h"
#include "chnk_make_mem.h"

extern vctr_rs_hmap_t *g_vctr_hmap;
extern chnk_rs_hmap_t *g_chnk_hmap;

// It creates memory at level "level" if necessary
int
vctr_make_mem(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    int level
    )
{
  int status = 0;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }
  if ( ( level < 1 ) || ( level > 2 ) ) { go_BYE(-1); } 

  bool vctr_is_found, chnk_is_found;
  uint32_t vctr_where_found, chnk_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  int num_chnks = g_vctr_hmap[tbsp].bkts[vctr_where_found].val.num_chnks;

  for ( int chnk_idx = 0; chnk_idx < num_chnks; chnk_idx++ ) { 
    status = chnk_is(tbsp, vctr_uqid, chnk_idx, &chnk_is_found,
        &chnk_where_found);
    cBYE(status);
    if ( !chnk_is_found ) { go_BYE(-1); }
    status = chnk_make_mem(tbsp, vctr_uqid, chnk_idx, level); cBYE(status);
  }
BYE:
  return status;
}
