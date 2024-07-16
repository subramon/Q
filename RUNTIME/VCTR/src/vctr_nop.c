#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_is.h"
#include "vctr_is.h"
#include "vctr_nop.h"
#include "chnk_nop.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

int
vctr_nop(
    uint32_t tbsp,
    uint32_t vctr_uqid
    )
{
  int status = 0;

  if ( vctr_uqid == 0 ) { go_BYE(-1); }

  bool vctr_is_found; uint32_t vctr_where_found;

  status = vctr_is(tbsp, vctr_uqid, &vctr_is_found, &vctr_where_found);
  cBYE(status);
  if ( !vctr_is_found ) { go_BYE(-1); }
  uint32_t min_chnk_idx = 
    g_vctr_hmap[tbsp].bkts[vctr_where_found].val.min_chnk_idx;
  uint32_t max_chnk_idx = 
    g_vctr_hmap[tbsp].bkts[vctr_where_found].val.max_chnk_idx;

  for ( uint32_t chnk_idx = min_chnk_idx; chnk_idx <= max_chnk_idx; 
      chnk_idx++ ) { 
    status = chnk_nop(tbsp, vctr_uqid, chnk_idx); 
    cBYE(status);
  }
BYE:
  return status;
}
